package engine.mvcs
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class EngineMediatorEvent extends Event
	{
		//======================================================================
		//  Class constants
		//======================================================================
		/**
		 * Trigger when a view is added to stage.
		 */
		public static const VIEW_ADDED:String = "viewAdded";
		/**
		 * Trigger when a view is removed from stage.
		 */
		public static const VIEW_REMOVED:String = "viewRemoved";
		
		/**
		 * Trigger when a view really activated
		 */
		public static const VIEW_ACTIVATED:String = "viewActivated";
		
		/**
		 * Trigger when a view deactivated
		 */
		public static const VIEW_DEACTIVATED:String = "viewDeactivated";
		
		//======================================================================
		//  Constructor
		//======================================================================
		/**
		 * Construct a <code>EngineMediatorEvent</code>.
		 * @param type  Type of the event.
		 * @param view  The view componet being added/removed.
		 */
		public function EngineMediatorEvent(type:String, view:DisplayObject)
		{
			super(type, true);
			_view = view;
		}
		//======================================================================
		//  Properties
		//======================================================================
		private var _data:Object;

		public function get data():Object { return _data;	}
		public function set data(value:Object):void {	_data = value;	}

		//------------------------------
		//  view
		//------------------------------
		private var _view:DisplayObject;
		/**
		 * The view componet being added/removed.
		 */
		public function get view():DisplayObject
		{
			return _view;
		}
		//======================================================================
		//  Overridden methods
		//======================================================================
		override public function clone():Event
		{
			return new EngineMediatorEvent(type, _view);
		}
	}
}