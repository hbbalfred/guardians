package engine.utils 
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import engine.framework.debug.Logger;

	/**
	 * JavaScript Utilities Class with several useful functions
	 * @author Tang Bo Hao
	 */
	public class JavaScriptUtils 
	{	
		protected static var _isJavaScriptAvailable:Boolean;
		protected static var _isJavaScriptAvailableKnown:Boolean;
		protected static var _SWFName:String;

		// ===!============= PUBLIC INTERFACE ======================
		// ------------------------------------------------------------
		/**
		 * Set cookie in HTML
		 * @param __name cookie name
		 * @param __value cookie value
		 * @param __expireDays expire
		 */
		public static function setCookie(__name:String, __value:String = "", __expireDays:Number = 0): void {
			
			if (!testJavascript()) return;
			
			var js:XML;
			js = <script><![CDATA[
				function(__name, __value, __expireDays) {
					var expDate = new Date();
					expDate.setDate(expDate.getDate() + __expireDays);
					document.cookie = escape(__name) + "=" + escape(__value) + ((__expireDays == 0) ? "" : ";expires=" + expDate.toGMTString()) + "; path=/";
				}
			]]></script>;
			
			ExternalInterface.call(js, __name, __value, __expireDays);
		}
		
		/**
		 * Get cookie from HTML
		 * @param __name
		 * @return 
		 */
		public static function getCookie(__name:String): String {
			
			if (!testJavascript()) return null;
			
			var js:XML;
			js = <script><![CDATA[
				function(__name) {
					var exp = new RegExp(escape(__name) + "=([^;]+)");
					if (exp.test (document.cookie + ";")) {
						exp.exec (document.cookie + ";");
						return unescape(RegExp.$1);
					} else {
						return "";
					}
				}
			]]></script>;
			
			return ExternalInterface.call(js, __name);
		}
		
		/**
		 * Get SWF Object Name
		 * Based on https://github.com/millermedeiros/Hasher_AS3_helper/blob/master/dev/src/org/osflash/hasher/Hasher.as
		 * Also http://blog.iconara.net/2009/02/06/how-to-work-around-the-lack-of-externalinterfaceobjectid-in-actionscript-2/
		 * @return String the SWF's object name for getElementById
		 */
		public static function getSWFObjectName(): String {
			
			// If already found, just return the existing name
			if (Boolean(_SWFName)) return _SWFName;
			
			if (Boolean(ExternalInterface.objectID)) return ExternalInterface.objectID;
			
			if (!testJavascript()) return null;
			
			// Reliable only if attributes.id and attributes.name is defined
			
			// Always work?
			// return ExternalInterface.call("function(){return this.attributes.id;}");
			
			var js:XML;
			js = <script><![CDATA[
				function(__randomFunction) {
					var check = function(objects){
						for (var i = 0; i < objects.length; i++){
							if (objects[i][__randomFunction]) return objects[i].id;
						}
						return undefined;
					};

					return check(document.getElementsByTagName("object")) || check(document.getElementsByTagName("embed"));
				}
			]]></script>;
			
			var __randomFunction:String = StringUtils.generatePropertyName();
			ExternalInterface.addCallback(__randomFunction, getSWFObjectName);
			
			_SWFName = ExternalInterface.call(js, __randomFunction);
			
			return _SWFName;
		}
		
		/**
		 * Open a popup window in browser
		 * @param __url
		 * @param __width
		 * @param __height
		 * @param __name
		 * @param __onClosed
		 */
		public static function openPopup(__url:String, __width:int = 600, __height:int = 400, __name:String = "_blank", __onClosed:Function = null): void {
			
			if (!testJavascript()) return;
			
			var js:XML;
			js = <script><![CDATA[
				function(__url, __width, __height, __name, __SWFContext, __onClosed) {

					//alert("caller is " + __SWFContext);
					//alert("caller is " + arguments.callee.caller.toString());

					if (__onClosed != "") {
						// If 'onClosed' is supplied, call a function when the popup window is closed

						var HTMLUtils_checkForWindow = function() {
							if (HTMLUtils_newWindow.closed) {
								clearInterval(HTMLUtils_windowCheckInterval);
								document.getElementById(__SWFContext)[__onClosed]();
							}
						};

						var HTMLUtils_windowCheckInterval = setInterval(HTMLUtils_checkForWindow, 250);
					}

					//http://www.yourhtmlsource.com/javascript/popupwindows.html

					var wx = (screen.width - __width)/2;
					var wy = (screen.height - __height)/2;

					var HTMLUtils_newWindow = window.open(__url, __name, "top="+wy+",left="+wx+",width="+__width+",height="+__height);
					if (HTMLUtils_newWindow.focus) HTMLUtils_newWindow.focus();
				}
			]]></script>;
			
			var __onClosedString:String = "";
			
			if (!ExternalInterface.available) {
				Logger.error( JavaScriptUtils, "openPopup", "No ExternalInterface available!");
				return;
			}
			
			if (Boolean(__onClosed)) {
				__onClosedString = StringUtils.generatePropertyName();
				ExternalInterface.addCallback(__onClosedString, __onClosed);
			} 
			
			ExternalInterface.call(js, __url, __width, __height, __name, getSWFObjectName(), __onClosedString);
		}
		
		/**
		 * Close current window 
		 */
		public static function closeWindow(): void {
			
			if (!testJavascript()) return;
			
			var js:XML;
			js = <script><![CDATA[
				function() {
					window.close();
				}
			]]></script>;
			
			ExternalInterface.call(js);
		}
		
		/**
		 * Reload current page
		 */
		public static function reload(): void {
			
			if (!testJavascript()) return;
			
			var js:XML;
			js = <script><![CDATA[
				function() {
					if( window.top ){
						window.top.reload();
					}else{
						window.location.reload();
					}
				}
			]]></script>;
			
			ExternalInterface.call(js);
		}
		
		/**
		 * Log at javascript console
		 */
		public static function log(param0:String):void
		{
			if (!testJavascript()) return;
			
			ExternalInterface.call("console.log", param0);
		}
		
		/**
		 * Launch a url in browser
		 * @param url
		 * @param target
		 * @param variables
		 */
		public static function launchURL(url:String, target:String="_blank", variables:Object=null):void
		{
			var browser:String = null;
			var useNavigateToURL:Boolean = true;
			
			// Check Browser
			try {
				if (ExternalInterface.available)
				{
					browser = ExternalInterface.call("function a() {return navigator.userAgent;}");
					if (!(browser == null) && (browser.indexOf("Firefox") < 1)){
						useNavigateToURL = true;
					} else {
						ExternalInterface.call("window.open", url, target, "");
						useNavigateToURL = false;
					};
				} else {
					useNavigateToURL = true;
				};
			} catch(error:SecurityError) {
				useNavigateToURL = true;
			};
			if (useNavigateToURL){
				var request:URLRequest = new URLRequest(url);
				if (variables){
					request.data = variables;
				};
				navigateToURL(request, target);
			};
		}
		
		// ===!============= ACCESSOR INTERFACE  ======================
		// ------------------------------------------------------------
		
		public static function get isJavaScriptAvailable(): Boolean {
			if (!_isJavaScriptAvailableKnown) {
				// Test to see if javascript is available
				
				if (ExternalInterface.available) {
					try {
						_isJavaScriptAvailable = ExternalInterface.call("function() { return true; }");
					} catch (e:Error) {
						_isJavaScriptAvailable = false;
					}
				} else {
					_isJavaScriptAvailable = false;
				}
				
				_isJavaScriptAvailableKnown = true;
				
			}
			return _isJavaScriptAvailable;
		}
		
		// ===!=============  INTERNAL INTERFACE ======================
		// ------------------------------------------------------------
		protected static function testJavascript(): Boolean {
			if (!isJavaScriptAvailable) {
				Logger.error(JavaScriptUtils, 'testJavascript', "no javascript available!");
				return false;
			}
			return true;
		}
	}
} 
