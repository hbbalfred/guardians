package engine.ui.decorators
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	
	/**
	 * @author zeh
	 */
	public class BlurDecorator extends AbstractDecorator {
		
		// Properties
		protected var _blurX:Number;
		protected var _blurY:Number;
		protected var _quality:Number;
		
		protected var _clearIfEmpty:Boolean;
		
		// ===!===== CONSTRUCTOR ============
		//  ---------------------------------
		
		public function BlurDecorator(__target:DisplayObject) {
			_blurX = 0;
			_blurY = 0;
			_quality = 1;
			
			_clearIfEmpty = true;
			
			super(__target);
		}
		
		// ===!===== INTERNAL FUNCTIONS  ============
		//  -----------------------------------------
		override protected function get filterClass():Class	{	return BlurFilter;	}
		
		override protected function apply(): void {
			var tempFilters:Array = _target.filters;
			var filterIndex:int = findFilter();
			
			if(filterIndex > -1 ) tempFilters.splice(filterIndex, 1);
			
			if (!(_blurX == 0 && _blurY == 0 && _clearIfEmpty) ){
				tempFilters.push(new BlurFilter(_blurX, _blurY, _quality));
			}
		
			_target.filters = tempFilters;
		}
		
		// ===!===== ACCESSOR FUNCTIONS  ============
		//  ----------------------------------------
		
		public function get blurX(): Number {
			return _blurX;
		}
		public function set blurX(__value:Number): void {
			if (_blurX != __value) {
				_blurX = __value;
				apply();
			}
		}
		
		public function get blurY(): Number {
			return _blurY;
		}
		public function set blurY(__value:Number): void {
			if (_blurY != __value) {
				_blurY = __value;
				apply();
			}
		}
		
		public function get quality(): Number {
			return _quality;
		}
		public function set quality(__value:Number): void {
			if (_quality != __value) {
				_quality = __value;
				apply();
			}
		}
	}
}