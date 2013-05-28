package engine.particle.core
{
	/**
	 * Action
	 * @author hbb
	 */
	public interface Action
	{
		/**
		 * execute action to the particle 
		 * @param p
		 */
		function execute( p:Particle, time:Number, emitter:Emitter ):void
	}
}