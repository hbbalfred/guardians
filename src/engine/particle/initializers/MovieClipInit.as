package engine.particle.initializers
{
	import engine.utils.FunctionUtils;
	
	import flash.display.MovieClip;
	
	import engine.particle.core.Particle;

	/**
	 * MovieClipInit
	 * @author hbb
	 */
	public class MovieClipInit extends AssetInit
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function MovieClipInit(className:String, domain:String=null, loop:Boolean = true, initObj:Object = null)
		{
			super(className, domain);
			
			_loop = loop;
			_initObj = initObj;
		}
		
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		/**
		 * @inheritDoc 
		 */
		override public function init(p:Particle):void
		{
			super.init(p);
			
			var mc:MovieClip = p.display;
			mc.loop = _loop;
			if( !_loop )
				mc.addFrameScript( mc.totalFrames - 1, mc.stop );
			
			if(_initObj)
				for(var i:String in _initObj)
					mc[i] = _initObj[i];
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _loop:Boolean;
		private var _initObj:Object;
	}
}