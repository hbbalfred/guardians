package engine.bevtree
{
	/**
	 * BevNodeTerminal
	 * @author hbb
	 */
	public class BevNodeTerminal extends BevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		public static const STA_READY:int = 0;
		public static const STA_RUNNING:int = 1;
		public static const STA_FINISH:int = 2;
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BevNodeTerminal(debugName:String=null)
		{
			super(debugName);
		}
		
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		final override protected function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):int
		{
			var isFinish:int = BRS_FINISH;
			
			if( _status == STA_READY )
			{
				doEnter( input );
				_needExit = true;
				_status = STA_RUNNING;
			}
			
			if( _status == STA_RUNNING )
			{
				isFinish = doExecute( input, output );
				if( isFinish == BRS_FINISH || isFinish < 0 )
					_status = STA_FINISH;
			}
			
			if( _status == STA_FINISH )
			{
				if(_needExit)
					doExit( input, isFinish );
				
				_status = STA_READY;
				_needExit = false;
			}
			
			return isFinish;
		}
		
		final override protected function doTransition(input:BevNodeInputParam):void
		{
			if( _needExit )
				doExit( input, BRS_ERROR_TRANSITION );
			
			_status = STA_READY;
			_needExit = false;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		protected function doEnter( input:BevNodeInputParam ):void
		{
			// nothing to do...implement yourself
		}
		
		protected function doExecute( input:BevNodeInputParam, output:BevNodeOutputParam ):int
		{
			return BRS_FINISH;
		}
		
		protected function doExit( input:BevNodeInputParam, exitID:int ):void
		{
			// nothing to do...implement yourself
		}
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _status:int = STA_READY;
		private var _needExit:Boolean;
	}
}