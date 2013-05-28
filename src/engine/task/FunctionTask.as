package engine.task
{
	
	/**
	 * Function Command for easily executing function
	 * @author TBH
	 */
	public class FunctionTask extends AbstractTask
	{	
		/**
		 * Function info Protected variables
		 */
		protected var _exe:FunctionWrapper;
		protected var _undo:FunctionWrapper;
		
		/**
		 * Game Command 
		 * @param	thisObj, context scope
		 * @param	fn, function
		 * @param	args, function arguments
		 */
		public function FunctionTask(thisObj:*, fn:Function, args:Array = null) 
		{
			super();
			
			_exe = new FunctionWrapper( thisObj, fn, args );
			_undo = _exe;
		}
		
		/**
		 * set undo command
		 * @param	undoObj, context scope of undo
		 * @param	fn, undo function
		 * @param	args, undo function arguments 
		 * @return	command self for link-style programming
		 */
		public function setUndo( undoObj:*, fn:Function, args:Array = null):FunctionTask
		{
			_undo = new FunctionWrapper( undoObj, fn, args );
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function execute():void
		{
			_exe.execute();
			this.complete();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function undo():void
		{
			_undo.execute();
			this.complete();
		}
		
		/**
		 * get function argument and can edit it
		 * @return
		 */
		public function get functionArguments():Array
		{
			return _exe.args;
		}
		
		/**
		 * get undo function argument and can edit it
		 * @return 
		 */
		public function get undoFunctionArguments():Array
		{
			return _undo.args;
		}
	}
}

class FunctionWrapper
{
	public var scope:*;
	public var fn:Function;
	public var args:Array;
	public function FunctionWrapper( scope:*, fn:Function, args:Array )
	{
		this.scope = scope;
		this.fn = fn;
		this.args = args || [];
	}
	public function execute():void
	{
		fn.apply(scope,args);
	}
}