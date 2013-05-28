package engine.render2D.animate
{
	import engine.utils.MathUtils;
	
	/**
	 * Sprite MutilWay Animation Component 
	 * @author hbb
	 * 
	 */
	public class SpriteMultiWayAnimComponent extends SpriteAnimComponent
	{

		/**
		 * the number of direction 
		 */
		public function get maxDirections():int{ return _maxDirections; }
		public function set maxDirections(v:int):void
		{
			if( v < 1 ) throw new ArgumentError("Error: you can NOT split direction in " + v + " parts");
			if( _maxDirections == v ) return;
			
			_directions = new Vector.<String>( v, true );
			
			_maxDirections = v;
			_radianPerDirection = MathUtils.TWO_PI / v;
		}
		
		/**
		 * offset radian of zero angle in parent coords
		 */
		public function get offsetRadian():Number{ return _offsetRadian; }
		public function set offsetRadian(v:Number):void
		{
			_offsetRadian = v;
		}
		
		/**
		 * register direction 
		 * @param index, which direction part
		 * @param name, direction name
		 * 
		 */
		public function registerDirection( index:int, name:String ):void
		{
			_directions[ index ] = name;
		}
		
		/**
		 * get direction by radian rotation
		 * @param radian
		 * @return
		 */
		public function getDirection( rotation:Number ):String
		{
			var index:int = MathUtils.wrapRadian( rotation - _offsetRadian ) / _radianPerDirection; 
			return _directions[ index ];
		}
		
		
		protected var _radianPerDirection:Number;
		protected var _maxDirections:int = -1;
		protected var _offsetRadian:Number = 0.0;
		protected var _directions:Vector.<String>;
	}
}