package engine.ui.comps
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import engine.framework.time.IAnimated;
	import engine.framework.time.TimeManager;
	import engine.ui.UICompFactory;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Simple MovieClip Playing UI
	 * @author Tang Bo Hao
	 */
	public class UIMovieClip extends UIComponent implements IAnimated
	{
		[PBInject] public var compFactory:UICompFactory;
		[PBInject] public var timeMgr:TimeManager;
		
		// >> Singals <<
		public const sig_Stoped:Signal = new Signal;
		
		private var _isReverse:Boolean = false;
		private var _isPlaying:Boolean = false;
		
		public function UIMovieClip(_id:String, _display:InteractiveObject, _owner:UIComponent)
		{
			super(_id, _display, _owner);
			
			// Add Stop to last Frame
			display.addFrameScript( display.totalFrames - 1, display.stop);
			display.stop();
		}
		
		override public function destroy():void
		{
			if( _isPlaying )
				timeMgr.removeAnimatedObject( this );
			
			sig_Stoped.removeAll();
			
			super.destroy();
		}
		
		// >> Accessors <<
		public function get display():MovieClip {	return this._display as MovieClip;	}
		public function get isReverse():Boolean {	return this._isReverse; }
		public function set isReverse( value:Boolean ):void { this._isReverse = value; }
		
		// >> Public functions <<
		/**
		 * restart and play the movieclip
		 */
		public function replay():void{
			if( !isReverse )
				display.gotoAndStop(1);
			else
				display.gotoAndStop( display.totalFrames );
			
			_isPlaying = true;
			timeMgr.addAnimatedObject( this ); 
		}
		
		/**
		 * to dispatch stop event
		 * @param e
		 */
		public function onFrame():void
		{
			var mc:MovieClip = this.display;
			if( !mc ) {
				timeMgr.removeAnimatedObject( this );
				return;
			}
			
			var lastFrame:int = isReverse ? 1 : mc.totalFrames;
			if( mc.currentFrame == lastFrame ){
				_isPlaying = false;
				timeMgr.removeAnimatedObject( this );
				this.sig_Stoped.dispatch();
			}else{
				display.gotoAndStop( display.currentFrame +  ( isReverse ? -1 : 1 ) );
			}
		}
		
		override protected function updateValue():void
		{
			if(this.value != null 
				&& ( this.value is Number 
					|| this.value is String) ) 
			{
				
				display.gotoAndStop(this.value);
				
				display.visible = true;
			}else{
				display.visible = false;
			}
		}
		
		override public function updateData(data:*):void
		{
			if( _linkedProperty || _mapFunc != null )
				this.value = this.getLinkedProperty(data);
		}
		
		override public function getChildByName(name:String):UIComponent
		{
			var childUI:UIComponent = super.getChildByName(name);
			
			// try get by name
			if( !childUI){
				var child:Sprite = DisplayObjectContainer(content).getChildByName("$base$"+name+"$$") as Sprite;
				if( child ){
					childUI = compFactory.createUI( child, null ); // tmp ui for MC
				}
			}
			
			return childUI;
		}
		
	}
}