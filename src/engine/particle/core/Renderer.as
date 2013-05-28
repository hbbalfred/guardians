package engine.particle.core
{
	/**
	 * Renderer
	 * @author hbb
	 */
	public interface Renderer
	{
		/**
		 * add the particle into render list
		 * @param p
		 */
		function addParticle( p : Particle ):Boolean;
		
		/**
		 * remove the particle from render list
		 * @param p
		 */
		function removeParticle( p : Particle ):Boolean;
		
		
		/**
		 * render all particles in render list
		 */
		function render():void;
		
		/**
		 * destroy renderer 
		 */
		function destroy():void;
	}
}