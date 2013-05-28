package engine.utils 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author Tang Bo Hao
	 */
	public class ArrayUtils 
	{	
		/**
		 * convert a xmllist to an array or xml's attribute to array
		 * @param xmllist
		 * @param attr if attr is not "", it will return the attribute 
		 * @return new Array
		 */
		public static function xmlListToArray(xmllist:XMLList, attr:String=""):Array
		{
			var xml:XML;
			var ret:Array = new Array();
			if (attr == ""){
				for each (xml in xmllist) {
					ret.push(xml);
				};
			} else {
				for each (xml in xmllist) {
					ret.push(String(xml.attribute(attr)));
				};
			};
			return ret;
		}
		
		/**
		 * shuffle the array
		 * @param __array
		 * @return 
		 */
		public static function shuffle(__array:Array): Array {
			// startIndex:int = 0, endIndex:int = 0):Array{ 
			// if(endIndex == 0) endIndex = this.length-1;
			var newArray:Array = [];
			while (__array.length > 0) {
				newArray.splice(Math.floor(Math.random() * (newArray.length+1)), 0, __array.pop());
			}
			
			return newArray;
		}
		
		
		/**
		 * get a array with all different element in arr1 and arr2
		 * @param arr1
		 * @param arr2
		 * @return new Array
		 */
		public static function arrayDiff(arr1:Array, arr2:Array):Array{
			var i:int;
			var tmp:Object;
			var ret:Array = new Array();
			var dicstore:Dictionary = new Dictionary();
			i = 0;
			while (i < arr1.length) {
				dicstore[arr1[i]] = true;
				i++;
			}
			i = 0;
			while (i < arr2.length) {
				if (dicstore[arr2[i]]){
					delete dicstore[arr2[i]];
				} else {
					ret.push(arr2[i]);
				};
				i++;
			}
			for (tmp in dicstore) {
				ret.push(tmp);
			}
			return (ret);
		}
		
		
		/**
		 * get an array with all intersect element in arr1 and arr2
		 * @param arr1
		 * @param arr2
		 * @return new Array
		 */
		public static function arrayIntersect(arr1:Array, arr2:Array):Array{
			var i:int;
			var ret:Array = new Array();
			var dicstore:Dictionary = new Dictionary();
			i = 0;
			while (i < arr1.length) {
				dicstore[arr1[i]] = true;
				i++;
			}
			i = 0;
			while (i < arr2.length) {
				if (dicstore[arr2[i]]){
					ret.push(arr2[i]);
				}
				i++;
			}
			return (ret);
		}
		
		/**
		 * Given an array of items and an array of weights,
		 * select a random item. Items with higher weights
		 * are more likely to be selected.
		 * 
		 */
		public static function selectRandomWeightedItem(items:Array, weights:Array):Object
		{
			var total:int = 0;
			var ranges:Array = [];
			for (var i:int = 0; i < items.length; i++)
			{
				ranges[i] = { start: total, end: total+weights[i] };
				total+=weights[i];   
			}
			
			var rand:int = Math.random()*total;
			
			var item:Object = items[0];
			
			for (i = 0; i < ranges.length; i++)
			{
				if (rand >= ranges[i].start && rand <= ranges[i].end)
				{
					item = items[i];
					break;
				}
			} 
			
			return item;
		}
		
		/**
		 * Return a sorted list of the keys in a dictionary
		 */
		public static function getSortedDictionaryKeys(dict:Object):Array
		{
			var keylist:Array = new Array();
			for (var key:String in dict)
			{
				keylist.push(key);
			}
			keylist.sort();
			
			return keylist;
		}
		
		
		/**
		 * Return a sorted list of the values in a dictionary
		 */
		public static function getSortedDictionaryValues(dict:Dictionary):Array
		{
			var valuelist:Array = new Array();
			for each (var value:Object in dict)
			{
				valuelist.push(value);
			}
			valuelist.sort();
			
			return valuelist;
		}
		
		/**
		 * generate a list of number with start and step 
		 */
		public static function generateNumberArray( length:int, start:Number = 0, step:Number = 1):Array
		{
			var a:Array = [];
			for(var i:int = 0; i < length; ++i)
			{
				a[i] = start + step * i;
			}
			return a;
		}

		public static function addToSet(arr:Array, value:*):void
		{
			if(arr.indexOf(value) < 0) {
				arr.push(value);
			}
		}
		
		public static function remove(arr:Array, value:*):void
		{
			arr.splice(arr.indexOf(value), 1);
		}
		
		public static function isSameSet(arr1:Array, arr2:Array):Boolean
		{
			if(arr1 == arr2) return true;
			if(arr1 == null || arr2 == null) return false;
			if(arr1.length != arr2.length) return false;
			var _arr1:Array = arr1.slice();
			var _arr2:Array = arr2.slice();
			_arr1.sort();
			_arr2.sort();
			for(var i:int = 0; i < arr1.length; i++) {
				if(arr1[i] != arr2[i]) return false;
			}
			return true;
		}
		
		public static function isSame(arr1:Array, arr2:Array):Boolean
		{
			if(arr1 == arr2) return true;
			if(arr1 == null || arr2 == null) return false;
			if(arr1.length != arr2.length) return false;
			for(var i:int = 0; i < arr1.length; i++) {
				if(arr1[i] != arr2[i]) return false;
			}
			return true;
		}
		
		/**
		 * For Array's Sort Result for string
		 * @param a
		 * @param b
		 * @param name
		 * @return 
		 */
		public static function stringSortResult( a:String, b:String, name:String ):int{
			if( a == name ){
				return -1;
			}else if (b == name){
				return 1;
			}else{
				return a < b ? -1 : 1;
			}
		}
	}
} 
