package engine.utils 
{
	import flash.system.Capabilities;
	import flash.system.System;
	
	/**
	 * Utilities Class with several useful functions
	 * Refer: https://github.com/zeh/as3/blob/master/com/zehfernando/utils/AppUtils.as
	 * @author Tang Bo Hao
	 */
	public class AppUtils 
	{
		/**
		 * Get current Stack trace
		 * @return String
		 */
		public static function getStackTrace():String
		{
			var stackTraceLines:Array = null;
			var lineToParse:String = null;
			var stackTrace:String = null;
			var result:String = "";
			var tempError:Error = new Error();
			
			// get StackTrack from error
			try {
				stackTrace = tempError.getStackTrace();
			} catch(e:Error) {
			};
			
			if (!(stackTrace == null) && !(stackTrace == ""))
			{
				stackTraceLines = stackTrace.split("\n", 5);
				lineToParse = String(stackTraceLines[4]);
				result = lineToParse.substring(4, (lineToParse.indexOf("()", 4) + 2));
			};
			return result;
		}
		
		public static function isMac(): Boolean {
			return Capabilities.os == "MacOS" || Capabilities.os.substr(0, 6) == "Mac OS";
		}
		
		public static function isLinux(): Boolean {
			return Capabilities.os == "Linux";
		}
		
		public static function isWindows(): Boolean {
			//return Capabilities.os == "Windows" || Capabilities.os == "Windows 7" || Capabilities.os == "Windows XP" || Capabilities.os == "Windows 2000" || Capabilities.os == "Windows 98/ME" || Capabilities.os == "Windows 95" || Capabilities.os == "Windows CE"; 
			//return Capabilities.os == "Windows" || Capabilities.os == "Windows 7" || Capabilities.os == "Windows XP" || Capabilities.os == "Windows 2000" || Capabilities.os == "Windows 98/ME" || Capabilities.os == "Windows 95" || Capabilities.os == "Windows CE"; 
			return Capabilities.manufacturer == "Adobe Windows";
		}
		
		public static function isAndroid(): Boolean {
			return Capabilities.manufacturer == "Android Linux";
		}
		
		public static function isStandalone(): Boolean {
			return Capabilities.playerType == "Desktop";
		}
		
		/**
		 * Returns true if the swf is built in debug mode
		 **/
		public static function isDebugBuild():Boolean
		{
			var debug:Boolean = false;
			
			CONFIG::debug
			{
				// If CONFIG::debug is defined as true, this line of
				// code gets executed and we overwrite the original value.
				debug = true;
			}
			
			return debug;
		}
		
		public static function isDebugPlayer(): Boolean {
			return Capabilities.isDebugger;
		}
		
		public static function copyToClipboard( txt:String ):void
		{
			System.setClipboard( txt );
		}
		
		public static function systemInfo():String
		{
			var str:String = "--SYSTEM INFO--" + "\n";
			str += "OS: " + Capabilities.os + "\n";
			str += "PLAYER TYPE: " + Capabilities.playerType + "\n";
			str += "PLAYER VERSION: " + Capabilities.version + "\n";
			str += "SCREEN: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + "\n";
			return str;
		}
	}
} 
