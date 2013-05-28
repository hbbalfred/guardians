package engine.bevtree
{
	/**
	 * BevNodeSequence
	 * @author hbb
	 */
	public class BevNodeSequence extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeSequence(debugName:String=null)
		{
			super(debugName);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			var index:int = _currentNodeIndex;
			if( index == -1 )
				index = 0;
			
			if( checkIndex( index ) )
			{
				if( _children[ index ].evaluate( input ) )
					return true;
			}
			
			return false;
		}
		
		override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var isFinish:int = BRS_FINISH;
			
			if( _currentNodeIndex == -1 )
				_currentNodeIndex = 0;
			
			isFinish = _children[ _currentNodeIndex ].tick( input, output );
			if( isFinish )
			{
				++_currentNodeIndex;
				if( _currentNodeIndex == _children.length )
					_currentNodeIndex = -1;
				else
					isFinish = BRS_EXECUTING;
			}
			
			if( isFinish < 0 ) // error
				_currentNodeIndex = -1;
			
			return isFinish;
		}
		
		override protected function doTransition(input:BevNodeInputParam):void
		{
			if( checkIndex( _currentNodeIndex ) )
				_children[ _currentNodeIndex ].transition( input );
			_currentNodeIndex = -1;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _currentNodeIndex:int = -1;
		
	}
}