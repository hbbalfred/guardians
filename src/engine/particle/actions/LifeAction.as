package engine.particle.actions
{
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	
	/**
	 * LifeAction
	 * @author hbb
	 */
	public class LifeAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function LifeAction()
		{
		}
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			p.lifecycle += time;
			
			p.isDead = p.lifecycleMax < p.lifecycle;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}