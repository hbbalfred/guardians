package engine.task
{
	import org.osflash.signals.Signal;

	/**
	 * Abstract Command for function calling easily
	 * @author Tang Bo Hao
	 */
	public class AbstractTask
	{
		/**
		 * use signal instead of event 
		 */
		public const sig_start:Signal = new Signal();
		public const sig_complete:Signal = new Signal();
		public const sig_fail:Signal = new Signal();
		
		/**
		 * define command status constants 
		 */
		public static const STA_WAITING:String = "waitingToBeExecuted";
		public static const STA_EXECUTING:String = "isExecuting";
		public static const STA_COMPLETE:String = "successful";
		public static const STA_FAILED:String = "failed";
		
		
		/**
		 * additional type name 
		 */
		private var _cmdType:String;
		public function get commandType():String
		{
			return _cmdType;
		}
		public function set commandType( value:String ):void
		{
			_cmdType = value;
		}
		
		
		/**
		 * Keeps track of this descriptor's command's execution status
		 * available status are: waiting, executing, complete 
		 */	
		private var _executionStatus:String;
		public function get executionStatus():String
		{
			return _executionStatus;
		}
		
		
		/**
		 * Constructor
		 * @param type, the specified command type
		 */
		public function AbstractTask(type:String = null)
		{
			_cmdType = type;
			
			_executionStatus = STA_WAITING;
		}
		
		/**
		 * clear 
		 */
		public function clear():void
		{
			sig_fail.removeAll();
			sig_complete.removeAll();
			sig_start.removeAll();
		}
		
		/** 
		 * Starts the command. 
		 */  
		public final function start():void
		{ 
			_executionStatus = STA_EXECUTING;
			
			if(sig_start.numListeners > 0)
				sig_start.dispatch(this);
			
			this.execute();
		}
		
		/**
		 * start to undo the commad 
		 */
		public final function startUndo():void
		{
			_executionStatus = STA_EXECUTING;
			
			this.undo();
		}
		
		/** 
		 * The abstract method for you to override to create your own command. 
		 */  
		protected function execute():void 
		{
			throw new Error("This is an abstract method, you must implement the own executtion!");
		}  
		
		/** 
		 * Completes the command. 
		 * Dispatches a complete event. 
		 */  
		protected final function complete():void
		{
			_executionStatus = STA_COMPLETE;
			
			sig_complete.dispatch(this);
		}
		
		/**
		 * Fail the command
		 * Dispatches a fail event. 
		 */
		protected final function fail():void
		{
			_executionStatus = STA_FAILED;

			sig_fail.dispatch(this);
		}
		
		/** 
		 * The abstract method for you to override to create your own command. 
		 */  
		protected function undo():void
		{
			throw new Error("This is an abstract method, you must implement the own undo!");
		}
	}
}