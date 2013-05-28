package engine.particle.actions
{
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	
	/**
	 * ColorAction
	 * @author hbb
	 */
	public class ColorAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function ColorAction()
		{
		}
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			p.rmul += p.vrmul;
			p.gmul += p.vgmul;
			p.bmul += p.vbmul;
			p.roff += p.vroff;
			p.goff += p.vgoff;
			p.boff += p.vboff;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}