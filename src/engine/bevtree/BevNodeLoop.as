package engine.bevtree
{
	/**
	 * BevNodeLoop
	 * @author hbb
	 */
	public class BevNodeLoop extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeLoop(debugName:String=null)
		{
			super(debugName);
		}
		
		public function setLoopCount( n:int ):BevNodeLoop
		{
			_loopCount = n;
			return this;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			var checkLoop:Boolean = (_loopCount == -1) || (_currentLoop < _loopCount);
			
			if(!checkLoop)
				return false;
			
			if( checkIndex(0) )
				if( _children[0].evaluate( input ) )
					return true;
			
			return false;
		}
		
		override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var isFinish:int = BRS_FINISH;
			
			if( checkIndex(0) )
			{
				isFinish = _children[0].tick( input, output );
				
				if( isFinish == BRS_FINISH )
				{
					if( _loopCount == -1 )
						isFinish = BRS_EXECUTING;
					else
					{
						++_currentLoop;
						if( _currentLoop < _loopCount )
							isFinish = BRS_EXECUTING;
					}
				}
			}
			
			if( isFinish == BRS_FINISH )
				_currentLoop = 0;
			
			return isFinish;
		}
		
		override protected function doTransition(input:BevNodeInputParam):void
		{
			if( checkIndex(0) )
				_children[0].transition( input );
			
			_currentLoop = 0;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _loopCount:int = -1;
		private var _currentLoop:int;
	}
}