package engine.task
{
	import engine.framework.time.TimeManager;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * Delay Command
	 * 
	 * @author hbb
	 */
	public class DelayTask extends AbstractTask
	{
		protected var _delay:Number;
		protected var _dueTime:Number;
		
		private var _timer:Timer;
		private var _timeMgr:TimeManager;
		private var _completed:Boolean;
		
		
		/**
		 * Command with delay time
		 * 
		 * @param delay, unit is millisecond
		 * @param type
		 * 
		 */
		public function DelayTask(delay:Number = 0, timeMgr:TimeManager = null, type:String = null)
		{
			super(type);
			
			_delay = delay > 0 ? delay : 0;
			_timeMgr = timeMgr;
		}
		
		/**
		 * task delay 
		 * @return 
		 */
		public function get delay():Number{ return _delay; }
		
		/**
		 * task due time
		 * @return
		 */
		public function get dueTime():Number {  return _dueTime;	}
		
		/**
		 * is the delay comleted
		 * @return
		 */
		public function get isCompleted():Boolean {	 return _completed; }
		
		/**
		 * finish instead of complete for public access 
		 */
		public function finish():void
		{
			if(_completed) return;
			_completed = true;
			
			this.complete();
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function clear():void
		{
			super.clear();
			_completed = true;
		}
		
		
		/** 
		 * The abstract method for you to override to create your own command. 
		 */  
		override protected function execute():void 
		{
			_completed = false;
			
			if(_delay == 0)
			{
				finish();
			}
			else
			{
				if(_timeMgr){					
					_timeMgr.schedule(_delay, this, finish);
					_dueTime = _timeMgr.virtualTime + _delay;
				}
				else
				{
					_timer = new Timer(_delay, 1);
					_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					_timer.start();
					_dueTime = getTimer() + _delay;
				}
				
			}
		}
		
		private function onTimerComplete(event:TimerEvent):void
		{
			var timer:Timer = event.target as Timer;
			if(timer)
			{
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer.stop();
				if(timer == _timer) _timer = null;
			}
			this.finish();
		}
		
		/**
		 * undo cloud looks like delay agian  
		 */
		override protected function undo():void
		{
			this.execute();
		}
	}
}