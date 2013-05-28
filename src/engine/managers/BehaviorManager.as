package engine.managers 
{
	import flash.utils.getTimer;
	
	import engine.EngineContext;
	import engine.framework.core.IPBManager;
	
	import org.osflash.signals.Signal;

	/**
	 * Behavior Center is a Singleton Class to handle all the game behavior and filter the behaviors or other things
	 * @author Tang Bo Hao
	 */
	public class BehaviorManager implements IPBManager
	{
		public static const LOGGING_QUERY_MAX:uint = 100; 
		
		// ================ Class Variable Define ================
		[PBInject]
		public var engineCxt:EngineContext;
		
		/**
		 * accept signal trigger if the behavior has accepted and not be locked 
		 */
		public const sig_accept:Signal = new Signal( String ); // bev id
		/**
		 * reject signal trigger if the behavior has rejected or be locked
		 */
		public const sig_reject:Signal = new Signal( String );  // bev id
		
		// lock and accept
		private var _lockall:Boolean;
		private var _acceptBehaviors:Object;
		
		// logging
		private var _logQuery:Vector.<String>;
		
		// ================ Constructor and Destructor ================
		/**
		 * initialize behavior manager 
		 */
		public function initialize():void
		{
			_lockall = false;
			_acceptBehaviors = {};
			
			// setup behavior logging
			_logQuery = new Vector.<String>;
		}
		
		/**
		 * destroy behavior manager 
		 * 
		 */
		public function destroy():void
		{
			_acceptBehaviors = null;
			_logQuery = null;
		}
		// ================= Public Functions ====================
		
		/**
		 * create a behavior signal.
		 * it is tranparent to external as a signal.
		 * 
		 * @param bid, behavior id
		 * @param params, parameters of signal to construct
		 * @return 
		 * 
		 */
		public function create( bid:String, ...params ):Signal
		{
			var sig:BehaviorSignal = BehaviorSignal.create.apply( BehaviorSignal, params ); 
			sig._id = bid;
			engineCxt.injectInto( sig );
			
			return sig;
		}
		
		
		/**
		 * lock/unlock all behavior signal.
		 * 
		 * it is used before prepare to accept/reject some behaviors
		 * 
		 * @param lock, whether lock or not
		 * @param clear, clear current accepting status of all behaviors
		 * 
		 */
		public function lockAll( lock:Boolean, clear:Boolean = true ):void
		{
			_lockall = lock;
			
			if(clear)
				_acceptBehaviors = {};
		}
		
		/**
		 * accept/reject the behavior signal can dispatch
		 * @param bid, behavior id
		 * @param accept true for accept, false for reject
		 */
		public function acceptBehavior(bid:String, accept:Boolean):void
		{
			_acceptBehaviors[ bid ] = accept ? 1 : -1;
		}
		
		/**
		 * get behavior log
		 * @param len
		 * @return 
		 */
		public function getLogEntry(len:uint = 0):Vector.<String>
		{
			if(len == 0 || len >= LOGGING_QUERY_MAX){
				return this._logQuery;
			}else{
				return this._logQuery.slice(0, len-1);
			}
		}
		
		// ================================= Private Functions =====================================
		
		/**
		 * check the behavior whether has locked 
		 * @param	bid behavior id
		 */
		internal function tryDoBehavior(bid:String):Boolean
		{
			//check if filtered
			var executable:Boolean;
			var status:int = _acceptBehaviors[ bid ];
			
			if( status > 0 )
				executable = true;
			else if( status < 0 )
				executable = false;
			else
				executable = !_lockall;
			
			if(!executable){// if can not execute, return
				if( sig_reject.numListeners > 0 )
					sig_reject.dispatch( bid );
				return false; 
			}
			
			// execute basic behavior function
			sig_accept.dispatch( bid );
			
			// behavior log
			this.logBehavior(bid, executable);
			
			return true;
		}
		
		/**
		 * Log current behavior, and clear old
		 * @param behaviorID
		 * @param executed
		 * @param cb_triggered
		 */
		private function logBehavior(behaviorID:String, executed:Boolean):void
		{
			var logStr:String = behaviorID+"::"+executed.toString()+"::"+ getTimer();
			
			// check max length of logQuery
			var len:uint = this._logQuery.unshift(logStr);
			if(len > LOGGING_QUERY_MAX){
				this._logQuery.pop();
			}
		}
		
	}
}
