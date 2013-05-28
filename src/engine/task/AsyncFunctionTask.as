package engine.task
{
	/**
	 * Async Function Task, you should invoke 'complete' in the function body manually
	 * @author Tang Bo Hao
	 */
	public class AsyncFunctionTask extends FunctionTask
	{
		/**
		 * Constructor
		 * @param thisObj
		 * @param fn the first argument should be 'complete' and second argument should be 'fail'
		 * @param args
		 */
		public function AsyncFunctionTask(thisObj:*, fn:Function, args:Array=null)
		{
			super(thisObj, fn, args);
			// add 'complete' and 'fail' as the function's first and second argument
			this.functionArguments.unshift(this.next);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function execute():void
		{
			_exe.execute();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function undo():void
		{
			_undo.execute();
		}
		
		/**
		 * if the game is
		 * @param isComplete
		 */
		public final function next(isComplete:Boolean = true):void
		{
			if(isComplete){
				this.complete();
			}else{
				this.fail();
			}
		}
	}
}