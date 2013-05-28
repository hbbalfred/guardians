package engine.utils
{
	/**
	 * Color utilities functions
	 * @author Tang Bo Hao
	 */
	public class ColorUtils
	{
		/**
		 * Color util, #000000 string to integer
		 * @param colorStr
		 * @return
		 */
		public static function hexColorToIntColor(colorStr:String):uint
		{
			var colorInt:uint;
			if (colorStr.length == 7){
				colorInt = parseInt(("0x" + colorStr.substr(1)));
			} else {
				if (colorStr.length == 6){
					colorInt = parseInt(("0x" + colorStr));
				};
			};
			return colorInt;
		}
		/**
		 * Golor util, integer to #000000 string
		 * @param colorInt
		 * @return 
		 */
		public static function intColorToHexColor(colorInt:uint):String
		{
			var colorStr:String = colorInt.toString(16);
			while (colorStr.length < 6) {
				colorStr = ("0" + colorStr);
			};
			return (colorStr.toUpperCase());
		}
	}
}