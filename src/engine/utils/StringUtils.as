package engine.utils 
{	
	import flash.utils.ByteArray;
	
	import engine.framework.debug.Logger;
	
	/**
	 * String Utilities Class with several useful functions
	 * @author Tang Bo Hao
	 */
	public class StringUtils 
	{
		public static const VALIDATION_EMAIL:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
		
		// ----- UID ------
		protected static var uniqueSerialNumber:int = 0;

		/**
		 * Generate unique number id ( Runtime UID )
		 * @return Number
		 */
		public static function getUniqueSerialNumber(): int {
			return uniqueSerialNumber++;
		}
		
		/**
		 * Generate an random String
		 * @param __chars
		 * @return
		 */
		public static function getRandomAlphanumericString(__chars:int = 1): String {
			// Returns a random alphanumeric string with the specific number of chars
			var chars:String = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";
			var i:int;
			
			var str:String = "";
			
			for (i = 0; i < __chars; i++) {
				str += chars.substr(Math.floor(Math.random() * chars.length), 1);
			}
			
			return str;
		}

		/**
		 * Generate a GUID
		 * @return 
		 */
		public static function generateGUID(): String {
			// http://en.wikipedia.org/wiki/Globally_unique_identifier
			// This one is actually more unorthodox
			var i:int;
			
			var nums:Vector.<int> = new Vector.<int>();
			nums.push(getUniqueSerialNumber());
			nums.push(getUniqueSerialNumber());
			for (i = 0; i < 10; i++) {
				nums.push(Math.round(Math.random() * 255));
			}
			
			var strs:Vector.<String> = new Vector.<String>();
			for (i = 0; i < nums.length; i++) {
				strs.push(("00" + nums[i].toString(16)).substr(-2,2));
			}
			var now:Date = new Date();
			
			var secs:String = ("0000" + now.getMilliseconds().toString(16)).substr(-4, 4);
			
			// 4-2-2-6
			return strs[0]+strs[1]+strs[2]+strs[3]+"-"+secs+"-"+strs[4]+strs[5]+"-"+strs[6]+strs[7]+strs[8]+strs[9]+strs[10]+strs[11];
		}
		
		/**
		 * Generate a random property name
		 * @return 
		 */
		public static function generatePropertyName(): String {
			return "f" + getRandomAlphanumericString(16) + ("00000000" + getUniqueSerialNumber().toString(16)).substr(-8,8);
		}
		
		/**
		 * Converts a String to a Boolean. This method is case insensitive, and will convert 
		 * "true", "t" and "1" to true. It converts "false", "f" and "0" to false.
		 * @param str String to covert into a boolean. 
		 * @return true or false
		 */		
		public static function stringToBoolean(str:String):Boolean
		{
			if (str==null)
				return false;
			switch(str.substring(1, 0).toUpperCase())
			{
				case "F":
				case "0":
					return false;
					break;
				case "T":
				case "1":
					return true;
					break;
			}
			
			return false;
		}
		
		/**
		 * Convert a number to 00,000,000 format
		 * @param __value
		 * @param __thousandsSeparator
		 * @param __decimalSeparator
		 * @param __decimalPlaces
		 * @return
		 */
		public static function formatNumber(__value:Number, __thousandsSeparator:String = ",", __decimalSeparator:String = ".", __decimalPlaces:Number = NaN): String 
		{
			var nInt:Number = Math.floor(__value);
			var nDec:Number = __value - nInt;
			
			var sInt:String = nInt.toString(10);
			var sDec:String;
			
			if (!isNaN(__decimalPlaces)) {
				sDec = (Math.round(nDec * Math.pow(10, __decimalPlaces)) / Math.pow(10, __decimalPlaces)).toString(10).substr(2);
			} else {
				sDec = nDec == 0 ? "" : nDec.toString(10).substr(2);
			}
			
			var fInt:String = "";
			var i:Number;
			for (i = 0; i < sInt.length; i++) {
				fInt += sInt.substr(i, 1);
				if ((sInt.length - i - 1) % 3 == 0 && i != sInt.length - 1) fInt += __thousandsSeparator;
			}
			
			return fInt + (sDec.length > 0 ? __decimalSeparator + sDec : "");
		}
		
		/**
		 * URL encoder
		 * @param __text
		 * @return 
		 */
		public static function URLEncode(__text:String): String {
			__text = escape(__text);
			__text = __text.split("@").join("%40");
			__text = __text.split("+").join("%2B");
			__text = __text.split("/").join("%2F");
			return __text;
		}
		
		/**
		 * Replaces instances of less then, greater then, ampersand, single and double quotes.
		 * @param str String to escape.
		 * @return A string that can be used in an htmlText property.
		 */		
		public static function escapeHTMLText(str:String):String
		{
			var chars:Array = 
				[
					{char:"&", repl:"|amp|"},
					{char:"<", repl:"&lt;"},
					{char:">", repl:"&gt;"},
					{char:"\'", repl:"&apos;"},
					{char:"\"", repl:"&quot;"},
					{char:"|amp|", repl:"&amp;"}
				];
			
			for(var i:int=0; i < chars.length; i++)
			{
				while(str.indexOf(chars[i].char) != -1)
				{
					str = str.replace(chars[i].char, chars[i].repl);
				}
			}
			
			return str;
		}
		
		/**
		 * test if the string is url
		 * @param str
		 * @return
		 */
		public static function isURL(str:String):Boolean
		{
			var reg:RegExp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
			return (reg.test(str));
		}
		
		
		/**
		 * Get a parameter value in a query string
		 * @param __url
		 * @param __parameterName
		 * @return 
		 */
		public static function getQuerystringParameterValue(__url:String, __parameterName:String): String {
			// Finds the value of a parameter given a querystring/url and the parameter name
			var qsRegex:RegExp = new RegExp("[?&]" + __parameterName + "(?:=([^&]*))?","i");
			var match:Object = qsRegex.exec(__url);
			
			if (Boolean(match)) return match[1];
			return null;
		}
		
		/**
		 * get a tag value from a string like 'tag="value"'
		 * @param str a string include a tag
		 * @param tag name
		 * @return the value of the tag
		 */
		public static function extractBasicTag(str:String, tag:String):String
		{
			var last:int;
			var ret:String;
			var first:int = str.indexOf(tag + "=\"");
			if (first != -1){
				first = (first + (tag.length + 2));
				last = str.indexOf("\"", first);
				if (last != -1){
					ret = str.substring(first, last);
				};
			};
			return (ret);
		}
		
		/**
		 * get a style value from a string like 'key:value;'
		 * @param str a string inclue style value
		 * @param key name
		 * @return the value
		 */
		public static function extractStyle(str:String, key:String):String
		{
			var last:int;
			str = str + ";";// add a default end
			var ret:String;
			var first:int = str.indexOf((key + ":"));
			if (first != -1){
				first = (first + (key.length + 1));
				last = str.indexOf(";", first);
				if (last != -1){
					ret = str.substring(first, last);
				};
			};
			return ret;
		}
		
		/**
		 * A wrapper function for ByteArray's uncompress and return String
		 * @param data
		 * @return 
		 */
		public static function uncompress(data:ByteArray):String
		{
			var compressedData:ByteArray = data;
			var compressedLength:uint = compressedData.length;
			try {
				compressedData.uncompress();
			} catch(e:Error) {
				throw (e);
			};
			
			Logger.info(StringUtils, "uncompress", "Loaded compressed localization file. Originally:"+compressedLength+"Decompressed:"+compressedData.length);
			return compressedData.toString();
		}
		
		/**
		 * Capitalize the first letter of a string 
		 * @param str String to capitalize the first leter of
		 * @return String with the first letter capitalized.
		 */		
		public static function capitalize(str:String):String
		{
			return str.substring(1, 0).toUpperCase() + str.substring(1);
		}
		
		/**
		 * Trim a string's space
		 * @param str
		 * @return new string
		 */
		public static function trimSpace(str:String):String
		{
			return str.replace(/^(\s| )+|(\s| )+$/g, "");
		}
		
		/**
		 * first split a string to array, then trim them
		 * @param str
		 * @param sp default is ","
		 * @return a new array
		 */
		public static function splitAndTrim(str:String, sp:String = ","):Array
		{
			var arr:Array = str.split(sp);
			var i:int;
			var len:int = arr.length;
			while (i < len) {
				arr[i] = trimSpace((arr[i] as String));
				i++;
			};
			return arr;
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
		
		/**
		 * Determine the file extension of a file. 
		 * @param file A path to a file.
		 * @return The file extension.
		 * 
		 */
		public static function getFileExtension(file:String):String
		{
			var extensionIndex:Number = file.lastIndexOf(".");
			if (extensionIndex == -1) {
				//No extension
				return "";
			} else {
				return file.substr(extensionIndex + 1,file.length);
			}
		}
		
		/**
		 * Isolate the file name from a full file path 
		 * @param file A path to a file.
		 * @return The file name without any path information.
		 * 
		 */
		public static function getFileName(filePath:String):String
		{
			return filePath.substr(filePath.lastIndexOf("/") + 1);
		}
		
		/**
		 * A Regular expression to match special Regular expression characters 
		 */
		public static const MATCH_SPECIAL_REGEXP:RegExp = new RegExp("([{}\(\)\^$&.\/\+\|\[\\\\]|\]|\-)","g");
		
		/**
		 * A Regular Expression for matching * and ? wildcard characters
		 */
		public static const MATCH_WILDCARDS_REGEXP:RegExp = new RegExp("([\*\?])","g");
		
		/**
		 * Match a wildcard pattern (*,?) with a given source string.
		 * 
		 * @return True if the pattern matches the source string 
		 */
		public static function matchWildcard(source:String, wildcard:String):Boolean
		{
			var regexp:String = wildcard.replace(MATCH_SPECIAL_REGEXP,"\\$1"); 
			regexp = "^" + regexp.replace(MATCH_WILDCARDS_REGEXP,".$1") + "$";
			return Boolean(source.search(regexp) != -1);
		}
		
		/**
		 * Return a new string that replaces the given search string with
		 * the replace string.
		 * @param str String to search in
		 * @param oldSubStr String to search for
		 * @param newSubStr String to replace.
		 */
		public static function replaceString(str:String, oldSubStr:String, newSubStr:String):String 
		{
			return str.split(oldSubStr).join(newSubStr);
		}
		
		/**
		 * Crop a western text
		 * @param __text text
		 * @param __maximumLength
		 * @param __breakAnywhere
		 * @param __postText
		 * @return
		 */
		public static function cropText(__text:String, __maximumLength:Number, __breakAnywhere:Boolean = false, __postText:String = ""):String {
			
			if (__text.length <= __maximumLength) return __text;
			
			// Crops a long text, to get excerpts
			if (__breakAnywhere) {
				// Break anywhere
				return __text.substr(0, Math.min(__maximumLength, __text.length)) + __postText;
			}
			
			// Break on words only
			var lastIndex:Number = 0;
			var prevIndex:Number = -1;
			while (lastIndex < __maximumLength && lastIndex > -1) {
				prevIndex = lastIndex;
				lastIndex = __text.indexOf(" ", lastIndex+1);
			}
			
			if (prevIndex == -1) {
				Logger.info(StringUtils,"cropText", "##### COULD NOT CROP ==> " + prevIndex + " " + lastIndex + " "+ __text);
				prevIndex = __maximumLength;
			}
			
			return __text.substr(0, Math.max(0, prevIndex)) + __postText;
		}
		
		public static function slugify(text:String):String {
			// Source: http://active.tutsplus.com/articles/roundups/15-useful-as3-snippets-on-snipplr-com/
			const pattern1:RegExp = /[^\w- ]/g; // Matches anything except word characters, space and -
			const pattern2:RegExp = /(\s| )+/g; // Matches one or more space characters
			var s:String = text;
			return s.replace(pattern1, "").replace(pattern2, "-").toLowerCase();
		}
		
		public static function wrapCDATA(text:String):String {
			return "<![CDATA[" + text + "]]>";
		}
		
		public static function stripDoubleCRLF(text:String): String {
			if (text == null) return null;
			return text.split("\r\n").join("\n");
		}
		
		
		/**
		 * 全角(SBC)和半角(DBC)相互转换，只支持ASCII
		 * 全角空格为12288，半角空格为32
		 * 其他字符半角(33-126)与全角(65281-65374)的对应关系是：均相差65248
		 * more: http://hardrock.cnblogs.com/archive/2005/09/27/245255.html
		 */
		
		/**
		 * 将给定字符串中的半角符号转为全角符号
		 * 
		 * @param	str
		 * @param	alsoSpace 空格是否也需要被转换
		 * @return	
		 */
		public static function toSBC(str:String, alsoSpace:Boolean = true):String
		{
			var a:Array = str.split('');
			var i:int = a.length;
			while (--i > -1)
			{
				var c:uint = str.charCodeAt(i);
				if(32 == c && alsoSpace)
					a[i] = String.fromCharCode(12288);
				else if(c>=33 && c<=126)
					a[i] = String.fromCharCode(c + 65248);
			}
			return a.join('');
		}
		
		/**
		 * 将给定字符串中的全角符号转为半角符号
		 * 
		 * @param	str
		 * @param	alsoSpace 空格是否也需要被转换
		 * @return	
		 */
		public static function toDBC(str:String, alsoSpace:Boolean = true):String
		{
			var a:Array = str.split('');
			var i:int = a.length;
			while (--i > -1)
			{
				var c:uint = str.charCodeAt(i);
				if(12288 == c && alsoSpace)
					a[i] = String.fromCharCode(32);
				else if(c>=65281 && c<=65374)
					a[i] = String.fromCharCode(c-65248);
			}
			return a.join('');
		}
	}
} 
