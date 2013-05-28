package engine.bevtree
{
	/**
	 * BevNodePreconditionTRUE
	 * @author hbb
	 */
	public class BevNodePreconditionTRUE extends BevNodePrecondition
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override public function evaluate(input:BevNodeInputParam):Boolean
		{
			return true;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
	}
}