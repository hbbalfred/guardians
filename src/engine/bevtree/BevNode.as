package engine.bevtree
{
	/**
	 * BevNode
	 * @author hbb
	 */
	public class BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		public static const BRS_EXECUTING:int = 0;
		public static const BRS_FINISH:int = 1;
		public static const BRS_ERROR_TRANSITION:int = -1;
		
		public static const MAX_CHILDREN:int = 16;
		
		// ----------------------------------------------------------------
		// :: Public Members
		/**
		 * debug name 
		 */
		public function get debugName():String{ return _debugName; }
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * constructor  
		 * @param debugName
		 */
		public function BevNode( debugName:String = null )
		{
			_debugName = debugName || "";
		}
		
		/**
		 * add a child of bevhaior node 
		 * @param node
		 * @return this
		 */
		final public function addChild( node:BevNode ):BevNode
		{
			if(!_children)
				_children = new Vector.<BevNode>;
			
			if(_children.length == MAX_CHILDREN)
				throw new Error( this + " overflow, max children number is " + MAX_CHILDREN);
			
			_children.push( node );
			node._parent = this;
			return this;
		}
		
		/**
		 * insert a child at the specified index 
		 * @param node
		 * @param index 
		 * @return this
		 */
		final public function addChildAt( node:BevNode, index:int ):BevNode
		{
			this.addChild( node );
			
			if(index < 0)
				index = 0;
			else if(index > _children.length - 1)
				index = _children.length;
			
			for(var i:int = _children.length - 1; i > index; --i)
				_children[i] = _children[i-1];
			
			_children[index] = node;
			
			return this;
		}
		
		/**
		 * set the precondition 
		 * @param precondition
		 * @return this 
		 */
		final public function setPrecondition( precondition:BevNodePrecondition ):BevNode
		{
			_precondition = precondition;
			return this;
		}
		
		/**
		 * evaluate the node whether execute or not 
		 * @param input, input param
		 * @return 
		 */
		final public function evaluate( input:BevNodeInputParam ):Boolean
		{
			var ret:Boolean = !_precondition || _precondition.evaluate( input );
			return ret && doEvaluate( input );
		}
		
		/**
		 * transition to another node 
		 */
		final public function transition( input:BevNodeInputParam ):void
		{
			doTransition( input );
		}
		
		/**
		 * on tick 
		 */
		final public function tick( input:BevNodeInputParam, output:BevNodeOutputParam ):int
		{
			return doTick( input, output );
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		/**
		 * inner evaluate 
		 * @param input
		 * @return 
		 */
		protected function doEvaluate( input:BevNodeInputParam ):Boolean
		{
			return true;
		}
		
		protected function doTransition( input:BevNodeInputParam ):void
		{
			// nothing to do ... implement yourself
		}
		
		protected function doTick( input:BevNodeInputParam, output:BevNodeOutputParam ):int
		{
			return BRS_FINISH;
		}
		
		final protected function checkIndex( i:int ):Boolean
		{
			return i > -1 && i < _children.length;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		protected var _debugName:String;
		protected var _precondition:BevNodePrecondition;
		protected var _children:Vector.<BevNode>;
		protected var _parent:BevNode;
	}
}