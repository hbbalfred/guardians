package engine.ui.decorators
{
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	
	/**
	 * @author zeh
	 */
	public class GlowDecorator extends AbstractDecorator {
		
		// Properties
		protected var _color:uint;
		protected var _alpha:Number;
		protected var _blurX:Number;
		protected var _blurY:Number;
		protected var _strength:Number;
		protected var _quality:Number;
		protected var _inner:Boolean;
		protected var _knockout:Boolean;
		
		protected var _clearIfEmpty:Boolean;
		
		// ===!===== CONSTRUCTOR ============
		//  ---------------------------------
		public function GlowDecorator(__target:DisplayObject) {
			_color = 0xFFFF00;
			_alpha = 1;
			_blurX = 10;
			_blurY = 10;
			_quality = 1;
			_strength = 0; // 0 is default 
			
			_clearIfEmpty = true;
			
			super(__target);
		}
		
		// ===!===== INTERNAL FUNCTIONS  ============
		//  -----------------------------------------
		override protected function get filterClass():Class	{	return GlowFilter;	}
		
		override protected function apply(): void {
			var tempFilters:Array = _target.filters;
			var filterIndex:int = findFilter();
			
			if(filterIndex > -1 ) tempFilters.splice(filterIndex, 1);
			
			var isClear:Boolean = (_blurX == 0 && _blurY == 0 && _clearIfEmpty) 
				|| (_strength == 0 && _clearIfEmpty)
				|| (_alpha == 0 && _clearIfEmpty);
			
			if (!isClear){
				tempFilters.push(new GlowFilter(_color, _alpha, _blurX, _blurY, _strength, _quality, _inner, _knockout));
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
		
		public function get strength():Number
		{
			return _strength;
		}
		public function set strength(value:Number):void
		{
			if(_strength != value){
				_strength = value;
				apply();
			}
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			if(_color != value){
				_color = value;
				apply();
			}
		}

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			if(_alpha != value){
				_alpha = value;
				apply();
			}
		}

		public function get inner():Boolean
		{
			return _inner;
		}

		public function set inner(value:Boolean):void
		{
			if(_inner != value){
				_inner = value;
				apply();
			}
		}

		public function get knockout():Boolean
		{
			return _knockout;
		}

		public function set knockout(value:Boolean):void
		{
			if(_knockout != value){
				_knockout = value;
				apply();
			}
		}

		
	}
}