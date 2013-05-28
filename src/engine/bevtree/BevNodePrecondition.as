package engine.bevtree
{
	/**
	 * BevNodePrecondition
	 * @author hbb
	 */
	public class BevNodePrecondition
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodePrecondition()
		{
		}
		
		public function evaluate( input:BevNodeInputParam ):Boolean
		{
			throw new Error("This is an abstract method. You need to implement yourself.");
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}