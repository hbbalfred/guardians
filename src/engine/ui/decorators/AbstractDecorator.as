package engine.ui.decorators
{
	import flash.display.DisplayObject;
	
	/**
	 * @author zeh
	 */
	public class AbstractDecorator {
		
		// Properties
		protected var _target:DisplayObject;
		protected var _delay:Number = 0;
		
		// ===!===== CONSTRUCTOR ============
		//  ---------------------------------
		
		public function AbstractDecorator(__target:DisplayObject) {
			_target = __target;
			apply();
		}
		
		public function set delay(value:Number):void
		{
			this._delay = value;
		}
		public function get delay():Number {	return _delay;	}
		
		// ===!===== INTERNAL INTERFACE ============
		// -----------------------------------------
		protected function apply(): void {
			throw new Error("This must be overridden.");
		}

		protected function get filterClass():Class	{
			throw new Error("This must be overridden."); 
		}
		
		protected function findFilter():int	{
			var len:int = _target.filters.length;
			for (var i:uint = 0; i < len ; i++) {
				if (_target.filters[i] is filterClass) {
					return i;
				}
			}
			return -1;
		}
		
		public function disable():void {
			
			var tempFilters:Array = _target.filters;
			var filterIndex:int = findFilter();
			if(filterIndex > -1 ) tempFilters.splice(filterIndex, 1);
			
			_target.filters = tempFilters;
		}
	}
}
