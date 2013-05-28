package engine.particle.zone
{
	import flash.geom.Point;
	
	import engine.particle.core.Zone;
	
	/**
	 * Rectangle
	 * @author hbb
	 */
	public class RectangleZone implements Zone
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function RectangleZone( x:Number = 0, y:Number = 0, w:Number = 100, h:Number = 100 )
		{
			_x = x;
			_y = y;
			_w = w;
			_h = h;
		}
		
		public function getPosition():Point
		{
			var pt:Point = new Point;
			
			pt.x = _x + Math.random() * _w;
			pt.y = _y + Math.random() * _h;
			
			return pt;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _x:Number;
		private var _y:Number;
		private var _w:Number;
		private var _h:Number;
	}
}