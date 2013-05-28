package engine.particle.core
{
	/**
	 * Initializer
	 * @author hbb
	 */
	public interface Initializer
	{
		/**
		 * initialize the particle 
		 * @param p
		 */
		function init( p:Particle ):void;
	}
}