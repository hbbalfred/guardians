package engine.particle.initializers
{
	import flash.display.BitmapData;
	
	import engine.particle.core.Initializer;
	import engine.particle.core.Particle;
	
	/**
	 * BitmapInit
	 * @author hbb
	 */
	public class BitmapInit implements Initializer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * create a wrapper for the specified BitmapData.
		 * @param bd
		 * @param smoothing
		 */
		public function BitmapInit( bd:BitmapData, smoothing:Boolean = false )
		{
			_bd = bd;
			_smoothing = smoothing;
		}
		
		public function init(p:Particle):void
		{
			p.display = _bd;//new Bitmap(_bd, PixelSnapping.AUTO, _smoothing);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _bd:BitmapData;
		private var _smoothing:Boolean;
	}
}