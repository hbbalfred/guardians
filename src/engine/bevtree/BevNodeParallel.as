package engine.bevtree
{
	/**
	 * BevNodeParallel
	 * @author hbb
	 */
	public class BevNodeParallel extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		public static const CON_OR:int = 0;
		public static const CON_AND:int = 1;
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeParallel(debugName:String=null)
		{
			super(debugName);
			
			resetChildrenStatus();
		}
		
		public function setFinishCondition( condition:int ):BevNodeParallel
		{
			_finishCondition = condition;
			return this;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override protected function doEvaluate(input:BevNodeInputParam):Boolean
		{
			var len:int = _children.length;
			for(var i:int = 0; i < len; ++i)
			{
				if( _childrenStatus[i] == BRS_EXECUTING )
				{
					if( !_children[i].evaluate( input ) )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var i:int;
			var len:int = _children.length;
			
			if( _finishCondition == CON_OR )
			{
				for( i = 0; i < len; ++i )
				{
					if( _childrenStatus[i] == BRS_EXECUTING )
						_childrenStatus[i] = _children[i].tick( input, output );
					
					if( _childrenStatus[i] != BRS_EXECUTING )
					{
						resetChildrenStatus();
						return BRS_FINISH;
					}
						
				}
			}
			else if( _finishCondition == CON_AND )
			{
				var finishedCount:int = 0;
				
				for( i = 0; i < len; ++i )
				{
					if( _childrenStatus[i] == BRS_EXECUTING )
						_childrenStatus[i] = _children[i].tick( input, output );
					
					if( _childrenStatus[i] != BRS_EXECUTING )
						++finishedCount;
				}
				
				if( finishedCount == len )
				{
					resetChildrenStatus();
					return BRS_FINISH;
				}
			}
			else
			{
				throw new Error("Unknown finish condition :" + _finishCondition);
			}
			
			return BRS_EXECUTING;
		}
		
		override protected function doTransition(input:BevNodeInputParam):void
		{
			resetChildrenStatus();
			
			var len:int = _children.length;
			for(var i:int = 0; i < len; ++i )
				_children[i].transition( input );
		}
		
		
		// ----------------------------------------------------------------
		// :: Private Methods
		private function resetChildrenStatus():void
		{
			for(var i:int = 0; i < MAX_CHILDREN; ++i )
				_childrenStatus[i] = BRS_EXECUTING;
		}
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _finishCondition:int = CON_OR;
		private var _childrenStatus:Vector.<int> = new Vector.<int>( MAX_CHILDREN, true );
	}
}