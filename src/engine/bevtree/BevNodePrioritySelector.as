package engine.bevtree
{
	/**
	 * BevNodePrioritySelector
	 * @author hbb
	 */
	public class BevNodePrioritySelector extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodePrioritySelector(debugName:String=null)
		{
			super(debugName);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			_currentSelectedIndex = -1;
			
			var len:int = _children.length;
			for(var i:int = 0; i < len; ++i)
			{
				if( _children[i].evaluate( input ) )
				{
					_currentSelectedIndex = i;
					return true;
				}
			}
			return false;
		}
		
		override protected function doTransition(input:BevNodeInputParam):void
		{
			if( checkIndex( _lastSelectedIndex ) )
			{
				_children[ _lastSelectedIndex ].transition( input );
			}
			_lastSelectedIndex = -1;
		}
		
		override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var isFinish:int = BRS_FINISH;
			
			if( checkIndex( _currentSelectedIndex ) )
			{
				if( _currentSelectedIndex != _lastSelectedIndex )
				{
					if( checkIndex( _lastSelectedIndex ) )
					{
						_children[ _lastSelectedIndex ].transition( input );
					}
					
					_lastSelectedIndex = _currentSelectedIndex;
				}
			}
			
			if( checkIndex( _lastSelectedIndex ) )
			{
				isFinish = _children[ _lastSelectedIndex ].tick( input, output );
				if( isFinish == BRS_FINISH )
					_lastSelectedIndex = -1;
			}
			
			return isFinish;
		}
		
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		protected var _currentSelectedIndex:int = -1;
		protected var _lastSelectedIndex:int = -1;
	}
}