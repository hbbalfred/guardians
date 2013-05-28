package engine.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * Bitmap utilities functions
	 * @author Tang Bo Hao
	 */
	public class BitmapUtils
	{
		// ----- BitmapData ------
		/**
		 * create a square bitmapdata to contain display
		 * @param display
		 * @return 
		 */
		public static function createSquareBitmapData(display:DisplayObject):BitmapData
		{
			var minLength:Number = Math.min(display.width, display.height);
			var startPnt:Point = new Point(((display.width - minLength) / 2), ((display.height - minLength) / 2));
			var mat:Matrix = new Matrix();
			mat.translate(-startPnt.x, -startPnt.y);
			// Draw the bmd
			var ret:BitmapData = new BitmapData(minLength, minLength, true, 0);
			ret.draw(display, mat);
			return (ret);
		}
		
		/**
		 * Create a Bitmap for displayobject with smooth param is true( it will take more time than false)
		 * @param display
		 * @return 
		 */
		public static function getSmoothableBitmap(display:DisplayObject):Bitmap
		{
			var bmpdata:BitmapData = new BitmapData(display.width, display.height, true, 0);
			bmpdata.draw(display, null, null, null, null, true);
			var ret:Bitmap = new Bitmap(bmpdata, "auto", true);
			return (ret);
		}
	}
}