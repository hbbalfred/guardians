package engine.ui.comps
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Point;
	
	import engine.managers.AssetsManager;
	import engine.ui.UICompFactory;
	import engine.utils.StringUtils;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Fx Component
	 * @author Tang Bo Hao
	 */
	public class UIFxComponent extends UIComponent
	{
		// >> Singals <<
		public const sig_PlayFinished:Signal = new Signal;
		
		[PBInject] public var stage:Stage;
		[PBInject] public var assetMgr:AssetsManager;
		[PBInject] public var uifacetory:UICompFactory;
		
		private var _fxclassname:String = null;
		private var _fxDomain:String = null;
		
		private var _isPlaying:Boolean = false;
		// boolean setting
		private var _isSingleton:Boolean = false;
		private var _isOnStage:Boolean = false;
		private var _dwf:Boolean = true;
		private var _fx:UIMovieClip;
		
		public function UIFxComponent(id:String, display:InteractiveObject, owner:UIComponent)
		{
			super(id, display, owner);
		}

		/**
		 * initialize with injected members
		 */
		override public function initialize():void
		{
			super.initialize();
			
			// try id as fx Class Name
			fxClassName = name;
		}

		public function set fxClassName( value:String ):void{	_fxclassname = value;	}
		public function get fxClassName():String { return _fxclassname; }
		public function set fxDomain(value:String):void{		_fxDomain = value; }
		public function get fxDomain():String	{	return _fxDomain;	}
		
		public function get isSingleton():Boolean {	return _isSingleton;	}
		public function set isSingleton(value:Boolean):void	{	_isSingleton = value;	}
		public function get isOnStage():Boolean{		return _isOnStage;	}
		public function set isOnStage(value:Boolean):void	{		_isOnStage = value;	}
		public function get destroyWhenFinished():Boolean{		return _dwf;	}
		public function set destroyWhenFinished(value:Boolean):void	{		_dwf = value;	}

		/**
		 * Invoke to generate FX
		 * The FX must be UIMovieClip 
		 * @return
		 */
		public function playFX():UIMovieClip
		{
			if( !_fxclassname ) return null;
			
			if( _isSingleton && _isPlaying) return null;
			
			var fxclass:Class = assetMgr.getClass( _fxDomain, _fxclassname);
			if( !fxclass ) return null;
			
			var mc:MovieClip = new fxclass;
			if( !mc ) return null;
			mc.name = "$mc$" + name + StringUtils.getUniqueSerialNumber() + "$$";
			mc.mouseChildren = false;
			mc.mouseEnabled = false;
			if( !_isOnStage ){
				DisplayObjectContainer(this.content).addChild( mc );
			}else{
				var gPos:Point = content.localToGlobal( new Point( 0,0 ) );
				mc.x = gPos.x;
				mc.y = gPos.y;
				stage.addChild( mc );
			}
			
			var fx:UIMovieClip = uifacetory.createUI(mc, this) as UIMovieClip;
			if( _isSingleton ){ _fx = fx; }
			fx.sig_Stoped.add( function():void{
				// dispatch finished
				sig_PlayFinished.dispatch( fx );
				removeChild( fx );
				
				if( !_dwf ) return;
				// destroy fx
				stopMC(fx);
			});
			fx.replay();
			_isPlaying = true;
			
			return fx;
		}
		
		public function stopFX():void{
			if( !_isSingleton || !_fx ) return;
			removeChild( _fx );
			_fx.sig_Stoped.removeAll();
			stopMC(_fx);
		}
		
		private function stopMC( fx:UIMovieClip ):void{
			var mc:MovieClip = fx.display;
			if( !_isOnStage ){
				if(mc && mc.parent)
					mc.parent.removeChild(mc);
			}else{
				stage.removeChild( mc );
			}
			fx.destroy();
			_isPlaying = false;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function destroy():void
		{
			this.sig_PlayFinished.removeAll();
			
			super.destroy();
		}
		
		
		public function get isPlaying():Boolean { return _isPlaying; }
	}
}