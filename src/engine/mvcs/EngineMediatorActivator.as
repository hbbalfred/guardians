package engine.mvcs
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	/**
	 * @author eidiot
	 * @author Tang Bo Hao
	 */
	public class EngineMediatorActivator
	{
		//======================================================================
		//  Constructor
		//======================================================================
		/**
		 * Construct a <code>EngineMediatorActivator</code>.
		 * @param view      View target.
		 * @param oneShot   If stop when the view is removed from stage.
		 */
		public function EngineMediatorActivator(view:DisplayObject, initData:*, oneShot:Boolean = false)
		{
			this.view = view;
			this.initData = initData;
			this.oneShot = oneShot;
			if (view.stage)
			{
				triggerActivateMediatorEvent();
			}
			else
			{
				view.addEventListener(Event.ADDED_TO_STAGE, view_addedToStageHandler);
			}
		}
		//======================================================================
		//  Variables
		//======================================================================
		private var view:DisplayObject;
		private var oneShot:Boolean;
		private var initData:*;
		
		//======================================================================
		//  Private methods
		//======================================================================
		private function triggerActivateMediatorEvent():void
		{
			var evt:EngineMediatorEvent = new EngineMediatorEvent(EngineMediatorEvent.VIEW_ADDED, view);
			evt.data = initData;
			
			view.dispatchEvent(evt);
			view.addEventListener(Event.REMOVED_FROM_STAGE, view_removedFromStageHandler);
		}
		private function triggerDeactivateMediatorEvent():void
		{
			view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_REMOVED, view));
			if (!oneShot)
			{
				view.addEventListener(Event.ADDED_TO_STAGE, view_addedToStageHandler);
			}
		}
		//======================================================================
		//  Event handlers
		//======================================================================
		private function view_addedToStageHandler(event:Event):void
		{
			view.removeEventListener(Event.ADDED_TO_STAGE, view_addedToStageHandler);
			triggerActivateMediatorEvent();
		}
		private function view_removedFromStageHandler(event:Event):void
		{
			view.removeEventListener(Event.REMOVED_FROM_STAGE, view_removedFromStageHandler);
			triggerDeactivateMediatorEvent();
		}
	}
}