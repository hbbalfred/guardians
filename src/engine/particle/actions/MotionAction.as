package engine.particle.actions
{
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	
	/**
	 * PropAction
	 * @author hbb
	 */
	public class MotionAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * modify all motion property by relative variable  
		 * 
		 */
		public function MotionAction()
		{
		}
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			p.x += p.vx;
			p.y += p.vy;
			p.scaleX += p.vscaleX;
			p.scaleY += p.vscaleY;
			p.rotation += p.vrotation;
			p.alpha += p.valpha;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}