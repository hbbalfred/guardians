package engine.bevtree
{
	/**
	 * BevNodeNonePrioritySelector
	 * @author hbb
	 */
	public class BevNodeNonePrioritySelector extends BevNodePrioritySelector
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeNonePrioritySelector(debugName:String=null)
		{
			super(debugName);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			if( checkIndex( _currentSelectedIndex ) )
			{
				if( _children[ _currentSelectedIndex ].evaluate( input ) )
				{
					return true;
				}
			}
			
			return super.doEvaluate( input );
		}
		
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}