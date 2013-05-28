package test
{
	import engine.bevtree.*;
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * Test1
	 * @author hbb
	 */
	public class Test1 extends Sprite
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function Test1()
		{
			super();
			
			if(stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			create();
			stage.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function create():void
		{
			// create behavior tree
			_root =
			new BevNodePrioritySelector("root")
			.addChild(
				new BevNodeSequence("move").setPrecondition( new HasSound )
				.addChild( new FaceTo )
				.addChild( new Idle )
				.addChild( new MoveTo )
				.addChild( new LookAround )
			)
			.addChild(
				new BevNodeParallel("patrol")
				.addChild( new Hovering )
				.addChild(
					new BevNodeNonePrioritySelector("smoking")
					.addChild(new Smoking().setPrecondition(new NoHasQiangDao))
					.addChild(new Coughing().setPrecondition(new NoHasCoughFeeling))
				)
			);
			
			// create data
			_input = new BevInputData;
			_output = new BevOutputData;
			_output.nextVelocity = new Point( 3, 0 );
			
			// create objects
			_soldier = new Soldier;
			_soldier.x = 200;
			_soldier.y = 200;
			this.addChild(_soldier);
			
			_txt = new TextField;
			this.addChild(_txt);
		}
		
		public function tick():void
		{
			// prepare data
			_input.target = _clickPos;
			_input.currPosition.x = _soldier.x;
			_input.currPosition.y = _soldier.y;
			_input.currVelocity.x = _output.nextVelocity.x;
			_input.currVelocity.y = _output.nextVelocity.y;
			_input.owner = _soldier;
			
			// ai
			if( _root.evaluate( _input ) )
			{
				_root.tick( _input, _output );
			}
			
			render();
		}
		
		public function render():void
		{
			const r2a:Number = 180 / Math.PI;
			
			_soldier.rotation = _output.faceDirection * r2a;
			_soldier.x = _output.nextPosition.x;
			_soldier.y = _output.nextPosition.y;
			
			_txt.text = _output.status;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		protected function onEnterFrame(e:Event):void
		{
			tick();
		}
		
		protected function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
		protected function onClick(e:MouseEvent):void
		{
			_clickPos = new Point( e.stageX, e.stageY );
			
			this.addChild( new SoundWave( e.stageX, e.stageY ) );
		}
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _root:BevNode;
		private var _input:BevInputData;
		private var _output:BevOutputData;
		private var _clickPos:Point;
		private var _soldier:Soldier;
		private var _txt:TextField;
	}
}
import engine.bevtree.*;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.Dictionary;

class SoundWave extends Shape
{
	public function SoundWave( x:Number, y:Number )
	{
		this.x = x;
		this.y = y;
		
		this.graphics.beginFill(0, 0.8);
		this.graphics.drawCircle(0,0,8);
		this.graphics.endFill();
		
		this.addEventListener(Event.ENTER_FRAME, update);
	}
	public function update(e:Event):void
	{
		if( this.alpha < 0.05 )
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
			if(this.parent)
				this.parent.removeChild(this);
			this.alpha = 0;
		}
		this.alpha *= 0.66;
		this.scaleX *= 1.1;
		this.scaleY = this.scaleX;
	}
}

class Soldier extends Sprite
{
	public function Soldier()
	{
		this.graphics.lineStyle(1,0);
		this.graphics.moveTo(20, -10);
		this.graphics.lineTo(20, +10);
		this.graphics.lineTo(30, 0);
		this.graphics.lineTo(20, -10);
		
		this.graphics.beginFill(0xffffff);
		this.graphics.drawCircle(0,0,25);
		this.graphics.endFill();
	}
	
	public var touchedTargets:Dictionary = new Dictionary;
}

class BevInputData extends BevNodeInputParam
{
	public var target:Point;
	public var currPosition:Point = new Point;
	public var currVelocity:Point = new Point;
	public var owner:Soldier;
}

class BevOutputData extends BevNodeOutputParam
{
	public var status:String = "";
	public var nextPosition:Point = new Point;
	public var nextVelocity:Point = new Point;
	public var faceDirection:Number;
}


class Smoking extends BevNodeTerminal
{
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var outputData:BevOutputData = BevOutputData(output);
		outputData.status = "smoking";
		return BRS_EXECUTING;
	}
}
class Coughing extends BevNodeTerminal
{
	override protected function doEnter(input:BevNodeInputParam):void
	{
		_times = 5;
	}
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var outputData:BevOutputData = BevOutputData(output);
		outputData.status = "coughing";
		
		if( --_times > 0 )
			return BRS_EXECUTING;
		else
			return BRS_FINISH;
	}
	
	private var _times:int = 0;
}
class Hovering extends BevNodeTerminal
{
	override protected function doEnter(input:BevNodeInputParam):void
	{
		_ticks = 0;
	}
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var inputData:BevInputData = BevInputData(input);
		var outputData:BevOutputData = BevOutputData(output);
		var v:Point = inputData.currVelocity.clone();
		
		if( ++_ticks % 20 == 0 )
		{
			v.x = -v.x;
			v.y = -v.y;
		}
		
		v.normalize( 3 );
		outputData.nextVelocity = v;
		outputData.nextPosition = inputData.currPosition.add( v );
		outputData.faceDirection = Math.atan2( v.y, v.x );
		
		return BRS_EXECUTING;
	}
	
	private var _ticks:int;
}
class FaceTo extends BevNodeTerminal
{
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var inputData:BevInputData = BevInputData(input);
		var outputData:BevOutputData = BevOutputData(output);
		
		var v:Point = inputData.target.subtract( inputData.currPosition );
		outputData.faceDirection = Math.atan2( v.y, v.x );
		
		return BRS_FINISH;
	}
}
class MoveTo extends BevNodeTerminal
{
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var inputData:BevInputData = BevInputData(input);
		var outputData:BevOutputData = BevOutputData(output);
		
		var v:Point = inputData.target.subtract(inputData.currPosition);
		
		if( v.length < inputData.currVelocity.length )
		{
			outputData.nextPosition = inputData.target.clone();
			return BRS_FINISH;
		}
		
		v.normalize( 10 );
		
		outputData.nextVelocity = v;
		outputData.nextPosition = inputData.currPosition.add( outputData.nextVelocity );
		outputData.faceDirection = Math.atan2( v.y, v.x );
		return BRS_EXECUTING;
	}
}
class LookAround extends BevNodeTerminal
{
	override protected function doEnter(input:BevNodeInputParam):void
	{
		_times = 3 + Math.random() * 3;
		_ticks = -1;
	}
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		var inputData:BevInputData = BevInputData(input);
		var outputData:BevOutputData = BevOutputData(output);
		
		if( ++_ticks % 12 == 0 )
		{
			outputData.faceDirection = Math.PI * 2 * Math.random();
			--_times;
		}
		
		if( _times > 0 )
			return BRS_EXECUTING;
		else
		{
			inputData.owner.touchedTargets[ inputData.target ] = true;
			outputData.nextVelocity.x = Math.cos( outputData.faceDirection ) * inputData.currVelocity.length;
			outputData.nextVelocity.y = Math.sin( outputData.faceDirection ) * inputData.currVelocity.length;
			return BRS_FINISH;
		}
	}
	
	private var _ticks:int;
	private var _times:int;
}
class Idle extends BevNodeTerminal
{
	override protected function doEnter(input:BevNodeInputParam):void
	{
		_waitTicks = 32;
	}
	override protected function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):int
	{
		if( --_waitTicks > 0 )
			return BRS_EXECUTING;
		else
			return BRS_FINISH;
	}
	
	private var _waitTicks:int;
}
class HasSound extends BevNodePrecondition
{
	override public function evaluate(input:BevNodeInputParam):Boolean
	{
		var inputData:BevInputData = BevInputData(input);
		var check:Boolean = inputData.target && !inputData.owner.touchedTargets[ inputData.target ];
		return check;
	}
}
class TouchSound extends BevNodePrecondition
{
	override public function evaluate(input:BevNodeInputParam):Boolean
	{
		var inputData:BevInputData = BevInputData(input);
		return inputData.currPosition.subtract( inputData.target ).length < 0.5;
	}
}
class NoHasQiangDao extends BevNodePrecondition
{
	override public function evaluate(input:BevNodeInputParam):Boolean
	{
		return Math.random() > 0.1;
	}
}
class NoHasCoughFeeling extends BevNodePrecondition
{
	override public function evaluate(input:BevNodeInputParam):Boolean
	{
		return Math.random() > 0.1;
	}
}