package engine.bevtree
{
	/**
	 * BevNodePreconditionNot
	 * @author hbb
	 */
	public class BevNodePreconditionNOT extends BevNodePrecondition
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodePreconditionNOT( a:BevNodePrecondition )
		{
			if( !a )
				throw new ArgumentError("Invalid arguments!");
			_a = a;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override public function evaluate(input:BevNodeInputParam):Boolean
		{
			return !_a.evaluate( input );
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _a:BevNodePrecondition;
	}
}