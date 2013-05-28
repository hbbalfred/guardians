package engine.particle.actions
{
	import flash.geom.Point;
	
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	import engine.particle.core.Zone;
	
	/**
	 * PositionAction
	 * @author hbb
	 */
	public class PositionAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function PositionAction( zone:Zone )
		{
			_zone = zone;
		}
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			var pt:Point = _zone.getPosition();
			
			p.x = pt.x;
			p.y = pt.y;
			
			emitter.localParticle(p);
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