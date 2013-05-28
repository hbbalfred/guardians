package engine.particle.zone
{
	import engine.utils.MathUtils;
	
	import flash.geom.Point;
	
	import engine.particle.core.Zone;
	
	/**
	 * EllipseZone
	 * @author hbb
	 */
	public class EllipseZone implements Zone
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function EllipseZone( centerX:Number, centerY:Number, radiusX:Number, radiusY:Number = -1 )
		{
			if( radiusY == -1 )
				radiusY = radiusX;
			
			_x = centerX;
			_y = centerY;
			_rx = radiusX;
			_ry = radiusY;
		}
		
		public function getPosition():Point
		{
			var pt:Point = new Point;
			var radian:Number = MathUtils.TWO_PI * Math.random();
			
			pt.x = _x + Math.cos( radian ) * _rx * Math.random();
			pt.y = _y + Math.sin( radian ) * _ry * Math.random();
			
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
		private var _rx:Number;
		private var _ry:Number;
	}
}