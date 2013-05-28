package engine.utils 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * This is a math utilities class 
	 * @author Tang Bo Hao
	 */
	public class MathUtils
	{
		/**
		 * Two times PI. 
		 */
		public static const TWO_PI:Number = 2.0 * Math.PI;
		
		/**
		 * factor of degrees to radians
		 */
		public static const D2R:Number = 180 / Math.PI;
		
		/**
		 * factor of radians to degrees 
		 */
		public static const R2D:Number = Math.PI / 180;
		
		/**
		 * Keep a number between a min and a max.
		 * @param v
		 * @param min
		 * @param max
		 * @return 
		 */
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
		{
			if(v < min) return min;
			if(v > max) return max;
			return v;
		}
		
		/**
		 * Converts an angle in radians to an angle in degrees.
		 * 
		 * @param radians The angle to convert.
		 * 
		 * @return The converted value.
		 */
		public static function getDegreesFromRadians(radians:Number):Number
		{
			return radians * D2R;
		}
		
		/**
		 * Converts an angle in degrees to an angle in radians.
		 * 
		 * @param degrees The angle to convert.
		 * 
		 * @return The converted value.
		 */
		public static function getRadiansFromDegrees(degrees:Number):Number
		{
			return degrees * R2D;
		}
		
		/**
		 * Take a radian measure and make sure it is between -pi..pi.
		 */
		public static function unwrapRadian(r:Number):Number
		{
			r = r % TWO_PI;
			if (r > Math.PI)
				r -= TWO_PI;
			if (r < -Math.PI)
				r += TWO_PI;
			return r;
		}
		
		/**
		 * Take a degree measure and make sure it is between -180..180.
		 */
		public static function unwrapDegrees(r:Number):Number
		{
			r = r % 360;
			if (r > 180)
				r -= 360;
			if (r < -180)
				r += 360;
			return r;
		}
		
		/**
		 * Take a radian measure and make sure it is between 0..2pi.
		 */
		public static function wrapRadian(r:Number):Number
		{
			r %= TWO_PI;
			if( r < 0 ) return r + TWO_PI;
			return r;
		}
		
		/**
		 * Take a degree measure and make sure it is between 0..360.
		 */
		public static function wrapDegrees(r:Number):Number
		{
			r %= 360;
			if( r < 0 ) return r + 360;
			return r;
		}
		
		/**
		 * Return the shortest distance to get from from to to, in radians.
		 */
		public static function getRadianShortDelta(from:Number, to:Number):Number
		{
			// Unwrap both from and to.
			from = unwrapRadian(from);
			to = unwrapRadian(to);
			
			// Calc delta.
			var delta:Number = to - from;
			
			// Make sure delta is shortest path around circle.
			if(delta > Math.PI)
				delta -= Math.PI * 2;            
			if(delta < -Math.PI)
				delta += Math.PI * 2;            
			
			// Done
			return delta;
		}
		
		/**
		 * Return the shortest distance to get from from to to, in degrees.
		 */
		public static function getDegreesShortDelta(from:Number, to:Number):Number
		{
			// Unwrap both from and to.
			from = unwrapDegrees(from);
			to = unwrapDegrees(to);
			
			// Calc delta.
			var delta:Number = to - from;
			
			// Make sure delta is shortest path around circle.
			if(delta > 180)
				delta -= 360;            
			if(delta < -180)
				delta += 360;            
			
			// Done
			return delta;
		}
		
		/**
		 * Get number of bits required to encode values from 0..max.
		 *
		 * @param max The maximum value to be able to be encoded.
		 * @return Bitcount required to encode max value.
		 */
		public static function getBitCountForRange(max:int):int
		{
			// TODO: Make this use bits and be fast.
			return Math.ceil(Math.log(max) / Math.log(2.0));
		}
		
		/**
		 * Returns the power of a number which is a power of 2.
		 */
		public static function getPowerOfTwo(value:uint):uint
		{
			// TODO: Find a faster way.
			return Math.log(value) * Math.LOG2E;
		}
		
		/**
		 * Pick an integer in a range, with a bias factor (from -1 to 1) to skew towards
		 * low or high end of range.
		 *  
		 * @param min Minimum value to choose from, inclusive.
		 * @param max Maximum value to choose from, inclusive.
		 * @param bias -1 skews totally towards min, 1 totally towards max.
		 * @return A random integer between min/max with appropriate bias.
		 * 
		 */
		public static function randomWithBias(min:int, max:int, bias:Number = 0):int
		{
			return clamp((Math.floor((Math.random() + bias) * (max - min + 1)) + min), min, max);
		}
		
		/**
		 * get a random int in range of a and b(not include)
		 * @param a
		 * @param b default is 0
		 * @return 
		 */
		public static function random(a:int, b:int=0):int
		{
			return Math.floor(Math.random() * (a - b)) + b;
		}
		
		/**
		 * get a random index in a arry
		 * @param arr
		 * @return 
		 */
		public static function randomIndex(arr:Array):int
		{
			return random(0, arr.length);
		}
		
		/**
		 * get a random Element of a arry 
		 * @param arr
		 * @return 
		 */
		public static function randomElement(arr:Array):*
		{
			return arr.length == 0 ? null : arr[randomIndex(arr)];
		}
		
		/**
		 * get a random index based on array's value 
		 * @param arr should be a array of Number
		 * @return int index
		 */
		public static function randomIndexWeighed(arr:Array):int{
			var tmp:Number;
			var weigh:Number = 0;
			var i:int;
			while (i < arr.length) {
				weigh = (weigh + arr[i]);
				i++;
			};
			var rand:Number = (Math.random() * weigh);
			i = 0;
			while (i < arr.length) {
				tmp = arr[i];
				if (rand < tmp){
					return i;
				};
				rand = (rand - tmp);
				i++;
			};
			return -1;
		}
		
		/**
		 * get a random Number in range of a*(1 - offset) and a*( 1 + offset) 
		 * @param a
		 * @param offset
		 * @return Number
		 */
		public static function randomWobble(a:Number, offset:Number):Number
		{
			var b:Number = offset * a;
			return a + (2 * Math.random() - 1) * b;
		}
		
		/**
		 * check if c is in abs(a-b)
		 * @param a
		 * @param b
		 * @param c
		 * @return 
		 * 
		 */
		public static function inEpsilonRange(a:Number, b:Number, c:Number):Boolean
		{
			return Math.abs(a - b) < c;
		}
		
		/**
		 * Calculate length of a vector. 
		 */
		public static function xyLength(x:Number, y:Number):Number
		{
			return Math.sqrt( x*x + y*y );
		}
		
		/**
		 * Calculate square length of a vector.
		 */
		public static function xyLengthQ(x:Number, y:Number):Number
		{
			return x*x + y*y;
		}
		
		/**
		 * get distance between two point
		 * @param p1
		 * @param p2
		 * @param dimen dimension, default is 2
		 * @return Number
		 */
		public static function distance(p1:Point, p2:Point, dimen:int=2):Number
		{
			var dx:Number = (p1.x - p2.x);
			var dy:Number = (p1.y - p2.y);
			// Fast case
			if (dimen == 2){
				return Math.sqrt((dx * dx) + (dy * dy));
			};
			// Fase case
			if (dimen == 1){
				return Math.abs(dx) + Math.abs(dy);
			};
			// need more time to calculate
			if (dimen > 0){
				return Math.pow(Math.pow(Math.abs(dx), dimen) + Math.pow(Math.abs(dy), dimen), (1 / dimen));
			};
			return ((dx)>dy) ? dx : dy;
		}
	}
} 
