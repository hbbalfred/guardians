package engine.ui.comps
{
	import engine.framework.debug.Logger;
	import engine.managers.AssetsManager;
	import engine.utils.DisplayObjectUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * UI MovieClip Loader
	 * @author Tang Bo Hao
	 */
	public class UIEmbedIconLoader extends UIIconLoader
	{
		public static var DEFAULT_DOMAIN:String = AssetsManager.DEFAULT_DOMAIN;
		
		protected var _embedIconDomain:String;

		private var _embedDisplay:DisplayObject;
		// Embed MovieClip
		private var _playTime:int = 1000;
		private var _startPlayTime:int;
		private var _smoothing:Boolean = false;
		
		public function UIEmbedIconLoader(id:String, display:Sprite, owner:UIComponent)
		{
			super(id, display, owner);
			
			if( DEFAULT_DOMAIN ){
				embedIconDomain = DEFAULT_DOMAIN;
			}
		}
		
		public function set embedIconDomain(value:String):void{		_embedIconDomain = value; }
		public function get embedIconDomain():String	{	return _embedIconDomain;	}

		/**
		 * MC Play Time
		 * @param value second
		 */
		public function set playTime(value:int):void	{	_playTime = value * 1000;	}
		public function get playTime():int{ return _playTime / 1000;	}
		
		
		/**
		 * bitmap smoothing 
		 */
		public function set smoothing(value:Boolean):void	{	_smoothing = value;	}
		public function get smoothing():Boolean{ return _smoothing; }
		
		
		/**
		 * @inhertDoc
		 */
		override protected function cleanIcon():void
		{
			if(_embedDisplay && _embedDisplay is MovieClip){
				_embedDisplay.removeEventListener(Event.ENTER_FRAME, this.on_playMovieClip);
			}
			super.cleanIcon();
		}
		
		/**
		 * @inhertDoc
		 */
		override protected function updateValue():void
		{
			var mcName:String = this.value;
			
			this.cleanIcon();
			
			if(mcName == null || mcName == this._currentImgName || embedIconDomain == null) return;
			
			try{
				var objCls:Class = this.assetsMgr.getClass(_embedIconDomain, mcName);
				var obj:* = new objCls;
			}catch(e:Error) {
				Logger.error(this, 'updateValue', 'Domain: [' + _embedIconDomain + '] McName: [' + mcName + '] is not define.');
				return;
			}
			
			if( obj is BitmapData){
				_embedDisplay = new Bitmap(obj,"auto",_smoothing);
			}else if(obj is DisplayObject){
				_embedDisplay = obj;
				if( _embedDisplay is MovieClip){
					MovieClip(_embedDisplay).stop();
					this._startPlayTime = getTimer();
					_embedDisplay.addEventListener(Event.ENTER_FRAME, this.on_playMovieClip);
				}
			}
			
			// Adjust size
			if(autoAdjust) DisplayObjectUtils.adjustSize( _embedDisplay, maxWidth, maxHeight );
			
			this._iconPoint.addChild(_embedDisplay);
			this._currentImgName = mcName;
		}
		
		/**
		 * Play the mc
		 * @param event
		 */
		protected function on_playMovieClip(event:Event):void
		{
			var now:int = getTimer();
			while ( now - _startPlayTime > _playTime ){
				_startPlayTime += _playTime;
			}
			
			var mc:MovieClip = _embedDisplay as MovieClip; 
			var process:int = (now - _startPlayTime) / _playTime * mc.totalFrames;
			mc.gotoAndStop( process );
		}
	}
}