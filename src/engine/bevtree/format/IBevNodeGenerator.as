package engine.bevtree.format
{
	import engine.bevtree.BevNode;
	import engine.bevtree.BevNodePrecondition;

	/**
	 * IBevNodeGenerator
	 * @author hbb
	 */
	public interface IBevNodeGenerator
	{
		/**
		 * generate a precondition by string 
		 * @param str, the specified string that is an expression hook in general
		 * @return a custom BevNodePrecondition class instance
		 */
		function precondition( str:String ):BevNodePrecondition;
		
		/**
		 * geenrate a behavior node by string 
		 * @param str, the specified string that is an expression hook in general
		 * @return a custom BevNode class instance or inner logic node such as BevNodeSequence..
		 * 
		 */
		function behavior( str:String ):BevNode;
	}
}