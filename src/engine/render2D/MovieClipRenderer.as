package engine.render2D
{
	import engine.managers.AssetsManager;
	
	import flash.display.MovieClip;

	/**
	 * MovieClip Renderer
	 * @author Tang Bo Hao
	 */
	public class MovieClipRenderer extends DisplayObjectRenderer
	{
		[PBInject] public var assetsMgr:AssetsManager;
		
		protected var _domain:String;
		protected var _className:String;
		protected var _loop:Boolean = true;
		protected var _playable:Boolean = true;
		
		private var _oldDomain:String;
		private var _oldClassName:String;
		
		/**
		 * @inheritDoc 
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			
			if(!this.displayObject)
				createMovieClip();
		}
		
		/**
		 * @inheritDoc 
		 */
		override protected function onRemove():void
		{
			_domain = null;
			_oldDomain = null;
			_className = null;
			_oldClassName = null;
			super.onRemove();
		}

		/**
		 * application domain of the movieclip
		 */
		public function get domain():String	{	return _domain;	}
		public function set domain(value:String):void
		{
			if(!value)
				return;
			
			_oldDomain = _domain;
			_domain = value;
		}

		/**
		 * a full class name of movie clip to render
		 * in general it is an exported class name from the flash ide
		 */
		public function get className():String	{	return _className;	}
		public function set className(value:String):void
		{
			if( !value )
				return;
			
			_oldClassName = _className;
			_className = value;
			
			createMovieClip();
		}
		
		/**
		 * rewind play or stop last frame 
		 */
		public function get loop():Boolean{ return _loop; }
		public function set loop(v:Boolean):void
		{
			_loop = v;
		}
		
		/**
		 * conveniently access displayobject with movieclip type 
		 */
		public function get mc():MovieClip{ return displayObject as MovieClip; }
		
		/**
		 * @inheritDoc 
		 */
		override protected function doFrame():void
		{
			if( _playable && this.displayObject )
				playing();
			
			super.doFrame();
		}
		
		/**
		 * update on frame 
		 */
		protected function playing():void
		{
			if( mc.currentFrame < mc.totalFrames )
				mc.nextFrame();
			else if( _loop )
				mc.gotoAndStop(1);
		}
		
		
		/**
		 * create movie clip 
		 */
		private function createMovieClip():void
		{
			if( !(assetsMgr && _domain && _className) )
				return;
			if( _domain == _oldDomain && _className == _oldClassName )
				return;
				
			var MC:Class = assetsMgr.getClass( _domain, _className ) as Class;
			this.displayObject = new MC();
			this.mc.stop();
		}
		
	}
}