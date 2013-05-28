package engine.utils.tracking
{	
	import engine.framework.debug.Logger;
	
	import flash.external.ExternalInterface;
	
	/**
	 * Based on https://github.com/zeh/as3/blob/master/com/zehfernando/utils/tracking/GAUtils.as author: Zeh Fernando
	 * @author Tang Bo Hao
	 */
	public class GATool {
		// Google analytics tracking
		protected static var _verbose:Boolean;						// If true, trace statements
		protected static var _simulated:Boolean;					// If true, doesn't actually make any post
		
		/*
		HTML should contain:
		
		<script type="text/javascript">
		var _gaq = _gaq || [];
		_gaq.push(['_setAccount', 'UA-XXXXXXX-X']);
		_gaq.push(['_trackPageview']);
		
		(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		})();
		
		</script>
		*/
		
		public function GATool() {
			throw new Error("You cannot instantiate this class.");
		}
		
		{
			_verbose = true;
			_simulated = false;
		}
		
		public static function trackPageView(__url:String): void {
			if (_verbose) Logger.print(GATool, "[" + __url + "]");
			if (!_simulated) ExternalInterface.call("function(__url){_gaq.push(['_trackPageview', __url]);}", __url);
		}
		
		public static function trackEvent(__category:String, __action:String, __label:String = null, __value:Number = 0): void {
			if (_verbose) Logger.print(GATool, "Category: ["+__category+"] Action:["+__action+"] Label:["+__label+"] Value:["+__value+"]");
			if (!_simulated) ExternalInterface.call("function(__category, __action, __label, __value){_gaq.push(['_trackEvent', __category, __action, __label, __value]);}", __category, __action, __label, __value);
		}
		
		public static function trackEventNumericLabel(__category:String, __action:String, __labelTemplate:String, __value:Number, __granularity:int, __algarisms:int, __maximum:Number = NaN, __minimum:Number = NaN, __minimumTemplate:String = "<[[max]]", __maximumTemplate:String = ">[[min]]"):void {
			
			var templateToUse:String = __labelTemplate;
			
			var valueConsidered:Number = __value;
			if (!isNaN(__minimum) && valueConsidered < __minimum) {
				valueConsidered = __minimum;
				templateToUse = __minimumTemplate;
			}
			if (!isNaN(__maximum) && valueConsidered > __maximum) {
				valueConsidered = __maximum;
				templateToUse = __maximumTemplate;
			}
			
			var valMin:Number = Math.floor(valueConsidered / __granularity) * __granularity;
			var valMax:Number = valMin + __granularity;
			
			var strMin:String = ("0000000000000" + valMin.toString(10)).substr(-__algarisms, __algarisms);
			var strMax:String = ("0000000000000" + valMax.toString(10)).substr(-__algarisms, __algarisms);
			
			var newLabel:String = templateToUse.split("[[min]]").join(strMin).split("[[max]]").join(strMax);
			
			trackEvent(__category, __action, newLabel, Math.round(__value)); // Apparently floating point numbers are breaking the script?!?
		}
		
		public static function get simulated(): Boolean {
			return _simulated;
		}
		public static function set simulated(__value:Boolean): void {
			if (_simulated != __value) {
				_simulated = __value;
				Logger.print(GATool, "simulated is " + _simulated);
			}
		}
		
		public static function get verbose(): Boolean {
			return _verbose;
		}
		public static function set verbose(__value:Boolean): void {
			if (_verbose != __value) {
				_verbose = __value;
				Logger.print(GATool, "verbose is " + _verbose);
			}
		}
	}
}