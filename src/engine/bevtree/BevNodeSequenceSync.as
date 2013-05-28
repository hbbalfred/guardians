package engine.bevtree
{
	/**
	 * BevNodeSequenceSync
	 * @author hbb
	 */
	public class BevNodeSequenceSync extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeSequenceSync(debugName:String=null)
		{
			super(debugName);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			var len:int = _children.length;
			for(var i:int = 0; i < len; ++i)
			{
				if( !_children[i].evaluate( input ) )
				{
					return false;
				}
			}
			
			return true;
		}
		
		override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var isFinish:int = BRS_FINISH;
			
			if( _currentNodeIndex == -1 )
				_currentNodeIndex = 0;
			
			while(true)
			{
				isFinish = _children[ _currentNodeIndex ].tick( input, output );
				
				if( isFinish != BRS_FINISH )
					break;
				
				if( ++_currentNodeIndex == _children.length )
				{
					_currentNodeIndex = -1;
					break;
				}
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