package engine.bevtree
{
	/**
	 * BevNodePreconditionFALSE
	 * @author hbb
	 */
	public class BevNodePreconditionFALSE extends BevNodePrecondition
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
			return false;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
	}
}