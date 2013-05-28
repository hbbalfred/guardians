package engine.managers
{
	import org.osflash.signals.Signal;
	
	/**
	 * BehaviorSignal
	 * 
	 * this is a core to control by behavior manager.
	 * 
	 * @author hbb
	 */
	internal class BehaviorSignal extends Signal
	{
		// ----------------------------------------------------------------
		// :: Static
		
		private static var _lock:Boolean = true;
		
		internal static function create( ...params ):BehaviorSignal
		{
			_lock = false;
			
			var ret:BehaviorSignal;
			if( params.length == 0 )
				ret = new BehaviorSignal();
			else if( params.length == 1 )
				ret = new BehaviorSignal( params[0] );
			else if( params.length == 2 )
				ret = new BehaviorSignal( params[0], params[1] );
			else if( params.length == 3 )
				ret = new BehaviorSignal( params[0], params[1], params[2] );
			else if( params.length == 4 )
				ret = new BehaviorSignal( params[0], params[1], params[2], params[3] );
			else if( params.length == 5 )
				ret = new BehaviorSignal( params[0], params[1], params[2], params[3], params[4] );
			else
				throw new Error("Error: too long parameters.");
			
			_lock = true;
			
			return ret;
		}
		
		// ----------------------------------------------------------------
		// :: Mebmers
		
		[PBInject] public var bevMgr:BehaviorManager;
		
		internal var _id:String;
		
		// ----------------------------------------------------------------
		// :: Getter/Setter
		
		
		// ----------------------------------------------------------------
		// :: Methods
		
		/**
		 * BehaviorSignal
		 */
		public function BehaviorSignal(...parameters)
		{
			super(parameters);
			
			if(_lock)
				throw new Error("Error: you can not create a new instance by constructor directly, instead by create of class method");
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function dispatch(...parameters):void
		{
			if( !_id )
				throw new Error("Error: invalid behavior signal");
			
			if( bevMgr.tryDoBehavior( _id ) )
				super.dispatch.apply( this, parameters );
		}
		
	}
}