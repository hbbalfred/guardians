package engine.particle.core
{
	/**
	 * Creator
	 * @author hbb
	 */
	public interface Creator
	{
		/**
		 * creator is actived
		 */
		function get isActived():Boolean;
		
		/**
		 * check the create condition in tick
		 * @time, delta time
		 * @return
		 */
		function check( time:Number ):Boolean;
		
		/**
		 * create particles 
		 * @return 
		 */
		function create():Vector.<Particle>;
	}
}