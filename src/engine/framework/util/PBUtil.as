/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package engine.framework.util
{
	/**
	 * Contains an assortment of useful utility methods.
	 */
	public class PBUtil
	{
		/**
		 * Keep a number between a min and a max.
		 */
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
		{
			if(v < min) return min;
			if(v > max) return max;
			return v;
		}
		
		/**
		 * Removes all instances of the specified character from 
		 * the beginning and end of the specified string.
		 */
		public static function trim(str:String, char:String):String {
			return trimBack(trimFront(str, char), char);
		}
		
		/**
		 * Recursively removes all characters that match the char parameter, 
		 * starting from the front of the string and working toward the end, 
		 * until the first character in the string does not match char and returns 
		 * the updated string.
		 */		
		public static function trimFront(str:String, char:String):String
		{
			char = stringToCharacter(char);
			if (str.charAt(0) == char) {
				str = trimFront(str.substring(1), char);
			}
			return str;
		}
		
		/**
		 * Recursively removes all characters that match the char parameter, 
		 * starting from the end of the string and working backward, 
		 * until the last character in the string does not match char and returns 
		 * the updated string.
		 */		
		public static function trimBack(str:String, char:String):String
		{
			char = stringToCharacter(char);
			if (str.charAt(str.length - 1) == char) {
				str = trimBack(str.substring(0, str.length - 1), char);
			}
			return str;
		}
		
		/**
		 * Returns the first character of the string passed to it. 
		 */		
		public static function stringToCharacter(str:String):String 
		{
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
		
    }
}