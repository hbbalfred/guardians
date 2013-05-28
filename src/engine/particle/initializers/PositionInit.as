package engine.particle.initializers
{
	import flash.geom.Point;
	
	import engine.particle.core.Initializer;
	import engine.particle.core.Particle;
	import engine.particle.core.Zone;
	
	/**
	 * PositionInit
	 * @author hbb
	 */
	public class PositionInit implements Initializer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function PositionInit( zone:Zone )
		{
			_zone = zone;
		}
		
		public function init(p:Particle):void
		{
			var pt:Point = _zone.getPosition();
			
			p.x = pt.x;
			p.y = pt.y;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _zone:Zone;
	}
}