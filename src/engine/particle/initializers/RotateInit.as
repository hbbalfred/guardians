package engine.particle.initializers
{
	import flash.geom.Point;
	
	import engine.particle.core.Initializer;
	import engine.particle.core.Particle;
	import engine.particle.zone.EllipseZone;
	
	/**
	 * RotateInit
	 * @author hbb
	 */
	public class RotateInit implements Initializer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function RotateInit( zone:EllipseZone )
		{
			_zone = zone;
		}
		
		public function init(p:Particle):void
		{
			var pt:Point = _zone.getPosition();
			
			p.rotation = Math.atan2( pt.y, pt.x ); 
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _zone:EllipseZone;
	}
}