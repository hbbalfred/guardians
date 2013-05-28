package engine.utils
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import engine.framework.debug.Logger;
	import engine.framework.util.TypeUtility;

	/**
	 * Utilities for common Objects
	 * @author Tang Bo Hao
	 */
	public class ObjectUtils
	{
		
		/**
		 * Extended typeof function
		 * @param obj
		 * @return 
		 */
		public static function typeOf(obj:*):String
		{
			if (obj is Array){
				return "array";
			};
			if (obj is Date){
				return "date";
			};
			return typeof(obj);
		}
		
		/**
		 * Check if is a empty object
		 * @param obj
		 * @return
		 */
		public static function isEmpty(obj:*):Boolean
		{
			for( var id:String in obj ){
				return false;
			}
			return true;
		}
		
		/**
		 * count members in a array or a object
		 * @param obj
		 * @return 
		 */
		public static function count(obj:Object):uint{
			var i:uint;
			var key:*;
			if (ObjectUtils.typeOf(obj) == "array"){
				return (obj.length);
			};
			i = 0;
			for (key in obj) {
				if (key != "mx_internal_uid"){
					i++;
				};
			};
			return i;
		}
		
		/**
		 * Set object's properties with the keys in options Object
		 * @param obj target Object
		 * @param options option object
		 */
		public static function setProperties(obj:*, options:Object):Object
		{
			obj ||= {};
			
			if(options != null){
				// check keys in options
				for( var key:String in options){
					if(obj.hasOwnProperty(key)){
						obj[key] = options[key];
					}
				}
			}
			
			return obj;
		}
		
		/**
		 * Deep copy properties from one object into another.
		 *
		 * @param source Object to copy properties from
		 * @param target (optional) Object to copy into. If null, a new object is created.
		 * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
		 * @return A deep copy of the object
		 */
		public static function copyAllProperties(source:Object, target:Object = null, abortOnMismatch:Boolean = false, primitiveOnly:Boolean = false):Object
		{
			// ObjectProxy
			if (source)
				source = source.valueOf();
			
			// Object
			target ||= {};
			var key:String;
			var value:Object;
			var classInfo:XML = TypeUtility.getTypeDescription(source);
			if (classInfo.@name.toString() != "Object")
			{
				// Sealed Object
				for each (var v:XML in classInfo..*.(
					name() == "variable" ||
					(
						name() == "accessor" &&
						attribute("access").charAt(0) == "r")
				))
				{
					if (v.metadata && v.metadata.(@name == "Transient").length() > 0)
						continue;
					
					key = v.@name.toString();
					
					attemptAssign(key, source, target, abortOnMismatch, primitiveOnly);
				}
			}
			
			// Dynamic fields
			for (key in source)
			{
				value = source[key];
				if (value is Function)
					continue;
				
				attemptAssign(key, source, target, abortOnMismatch, primitiveOnly);
			}
			
			return target;
		}
		
		/**
		 * Assign a single field from the source object to the destination. Also handles assigning
		 * nested typed vectors of objects. In the destination object class, add a TypeHint to the 
		 * field that contains the Vector like so:
		 * 
		 * [TypeHint (type="liddles.models.BodyPartDescription")]
		 * public var parts:Vector.<BodyPartDescription>;
		 * 
		 * @param source Object to read fields from.
		 * @param dest Object to assign fields to.
		 * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
		 */
		private static function attemptAssign(fieldName:String, source:Object, destination:Object, abortOnMismatch:Boolean, primitiveOnly:Boolean):void
		{	
			var value:* = source[fieldName];
			var newValue:*;
			var typeName:String;
			var targetobj:Object = null;
			
			// Primitive
			if (value is String ||
				value is Number ||
				value is uint ||
				value is int ||
				value is Boolean ||
				value == null)
			{
				newValue = value;
			} else if (value is Array || value is Vector.<*>)
			{
			// source is an array?
				var tmpArray:Object=null;
				
				// See if we have a type hint for objects in the array
				// by looking at the destination field
				typeName = TypeUtility.getTypeHint(destination,fieldName);
				
				if (typeName && ! primitiveOnly)
				{
					var vectorType:String = "Vector.<"+typeName+">";
					tmpArray = TypeUtility.instantiate(vectorType);
					
					for each (var val:Object in value)
					{
						if (typeName)
						{
							targetobj = TypeUtility.instantiate(typeName);
						}				
						else
						{
							targetobj = new Object();
						}
						
						tmpArray.push(copyAllProperties(val, targetobj, abortOnMismatch));
					}
				}
				else
				{
					tmpArray ||= [];
					var fromArray:Array = value as Array;
					var len:int = fromArray.length;
					for (var i:int = 0; i < len; i++) {
						var v:* = fromArray[i];
						// Primitive
						if (v is String ||
							v is Number ||
							v is uint ||
							v is int ||
							v is Boolean ||
							v == null)
						{
							tmpArray[i] = v;
						} else {
							tmpArray[i] = copyAllProperties(fromArray[i], {}, abortOnMismatch);
						}
					}
				}
				
				newValue = tmpArray;					
			}
			else
			{
				typeName = TypeUtility.getFieldType(destination,fieldName);
				
				if (typeName && !primitiveOnly)
				{
					targetobj = TypeUtility.instantiate(typeName);
				}				
				else
				{
					targetobj = new Object();
				}
				newValue = copyAllProperties(value, targetobj, abortOnMismatch);
			}
			
			try
			{
				// Try to assign.
				destination[fieldName] = newValue;
			}
			catch(e:Error)
			{
				// Abort or continue, depending on user settings.
				if(!abortOnMismatch)
					return;
				throw new Error("Field '" + fieldName + "' in source was not present in destination.");
			}
		}
		/**
		 * Make a deep copy of an object.
		 * 
		 * Only really works well with all-public objects, private/protected
		 * fields will not be respected.
		 *  
		 * @param source Object to copy.
		 * @return New instance of object with all public fields set.
		 * 
		 */
		public static function clone(source:Object, primitiveOnly:Boolean = false):* 
		{
			var clone:Object;
			if(!source)
				return null;
			if(primitiveOnly) {
				clone = new Object;
			} else {
				clone = TypeUtility.instantiate(TypeUtility.getObjectClassName(source));
			}
			
			if(clone) 
				return copyAllProperties(source, clone, primitiveOnly);
			else
				return null;
		}
		
		/**
		 * Make a deep copy of an object， will lose some customized class 
		 * @param source
		 * @return a new object
		 */
		public static function cloneObject( source:Object ):Object
		{
			var ba:ByteArray = new ByteArray;
			ba.writeObject( source );
			ba.position = 0;
			return ba.readObject();
		}
		
		/**
		 * Instantiate a new object of the same type passed in to this 
		 * function.  
		 * 
		 * This does not copy any properties from the object, it simply
		 * instantiates a new object of the same type.  
		 * 
		 * @param obj The object to create an empty copy of
		 * @return A new object of the type passed in to the function
		 */
		public static function instantiateCloneObject(obj:Object):Object
		{
			var sourceClass:Class = Object(obj).constructor;
			return new sourceClass();
		}
		
		/**
		 * Transform static constant(Enums) defined in Class to an array 
		 * @param className
		 * @return
		 */
		public static function enumsArray(className:Class):Array
		{
			var retNames:Array = new Array;
			
			var enumLists:XMLList = describeType(className).child("constant");
			for each(var enum:XML in enumLists)
			{
				retNames.push(XML(enum.@name).toString());
			}
			
			return retNames;
		}
		
		public static var dumpRecursionSafety:Dictionary = new Dictionary();
		
		/**
		 * Log an object to the console. Based on http://dev.base86.com/solo/47/actionscript_3_equivalent_of_phps_printr.html 
		 * @param thisObject Object to display for logging.
		 * @param obj Object to dump.
		 */
		public static function dumpObjectToLogger(thisObject:*, obj:*, level:int = 0, output:String = ""):String
		{
			var tabs:String = "";
			for(var i:int = 0; i < level; i++) 
				tabs += "\t";
			
			var fields:Array = TypeUtility.getListOfPublicFields(obj);
			
			for each(var child:* in fields) 
			{
				// Only dump things once.
				if(dumpRecursionSafety[child] == 1)
					continue;
				dumpRecursionSafety[child] = 1;
				
				output += tabs +"["+ child +"] => "+ obj[child];
				
				var childOutput:String = dumpObjectToLogger(thisObject, obj[child], level+1);
				if(childOutput != '') output += ' {\n'+ childOutput + tabs +'}';
				
				output += "\n";
			}
			
			if(level == 0)
			{
				// Clear the recursion safety net.
				dumpRecursionSafety = new Dictionary();
				
				Logger.print(thisObject, output);
				return output;
			}
			
			return output;
		}
		
		/**
		 * replace all string deep in Object
		 * @param obj
		 * @param replReg
		 * @param vo
		 * @return 
		 */
		public static function deepReplaceString( obj:Object, replReg:RegExp, vo:Object ):Object
		{
			if(replReg == null || vo == null) return null;

			// for array
			if(obj is Array){
				(obj as Array).forEach(function(item:*, index:int, ...rest):void{
					obj[index] = deepReplaceString( item, replReg, vo);
				});
				return obj;
			}
			
			// for object
			var fields:Array = TypeUtility.getListOfPublicFields(obj);
			
			for each(var child:* in fields) 
			{
				var value:* = obj[child];
				
				// Primitive
				if (value is Number ||
					value is uint ||
					value is int ||
					value is Boolean ||
					value == null)
				{
					continue;
				}
				
				if( !(value is String) ){
					obj[child] =  deepReplaceString( value, replReg, vo);
					continue;
				}
				
				obj[child] = String(value).replace( replReg , function(find:String, match:String, ...rest):String{
					if(vo[match] && vo[match] is String){
						return vo[match];
					}else{
						return match;
					}
				});
			}
			
			return obj;
		}
		/**
		 * get the property value of an object
		 * @param {Object} obj
		 * @param {String} property
		 * 		you can use .
		 */
		public static function getProperty(obj:*, propName:String):* {
			var props:Array = propName.split(".");
			var curr:* = obj;
			while(curr && props.length > 0){
				curr = curr[props.shift()];
			}
			return curr;
		}

		/**
		 * set property value of an object
		 * @param {*} obj
		 * @param {String} property
		 * @param value
		 */
		public static function setProperty(obj:*, propName:String, value:*):void {
			var props:Array = propName.split(".");
			var curr:* = obj;
			while(curr && props.length > 1){
				curr = curr[props.shift()];
			}
			if( !curr ) return;
			curr[props.shift()] = value;
		}
		
		
		/**
		 * Get sum value
		 * @param tarProp
		 * @param tarId
		 * @return 
		 */
		public static function getSumValue( source:Object, target:String, tarId:String, tarProp:String):int{
			var obj:* = ObjectUtils.getProperty( source, target );
			if( !obj ) return 0;
			
			var idreg:RegExp = new RegExp(tarId,"i");
			var mat:Array, retValue:int = 0, tarObj:Object;
			for( var id:String in obj ){
				mat = id.match( idreg );
				if( mat && mat.length){
					tarObj = obj[id];
					if( tarObj is int ){
						retValue += (tarObj as int) || 0;
					}else if( tarProp ){
						tarObj = ObjectUtils.getProperty( tarObj, tarProp );
						retValue += (tarObj as int ) || 0;
					}
				}
			}
			return retValue;
		}
		
		/**
		 * get some value
		 * @param tarProp
		 * @param tarId
		 * @return 
		 */
		public static function getSomeValue( source:Object, target:String, tarId:String, tarProp:String):int{
			var obj:* = ObjectUtils.getProperty( source, target );
			if( !obj ) return 0;
			
			var idreg:RegExp = new RegExp(tarId,"i");
			var mat:Array, retValue:int = 0, tarObj:Object;
			for( var id:String in obj ){
				mat = id.match( idreg );
				if( mat && mat.length){
					tarObj = obj[id];
					if( !(tarObj is int ) && tarProp ){
						tarObj = ObjectUtils.getProperty( tarObj, tarProp );
					}
					if( (tarObj as int ) > retValue ){
						retValue = (tarObj as int);
					}
				}
			}
			return retValue;
		}
		
		
		/**
		 * get count value
		 * @param tarProp
		 * @param tarId
		 * @return 
		 */
		public static function getCountValue( source:Object, target:String, tarId:String ):int{
			var obj:* = ObjectUtils.getProperty( source, target );
			if( !obj ) return 0;
			
			var idreg:RegExp = new RegExp(tarId,"i");
			var mat:Array, retValue:int = 0;
			for( var id:String in obj ){
				mat = id.match( idreg );
				if( mat && mat.length){
					retValue++;
				}
			}
			return retValue;
		}
		
		/**
		 * get in array
		 * @param tarProp
		 * @param tarId
		 * @return 
		 */
		public static function getInArray( source:Object, target:String, tarId:String, ...args):int{
			var obj:* = ObjectUtils.getProperty( source, target );
			if( obj is Array ){
				return int( (obj as Array).indexOf( tarId ) > -1 );
			}else{
				return 0;
			}
		}
		
		/**
		 * get in array
		 * @param tarProp
		 * @param tarId
		 * @return 
		 */
		public static function countArray( source:Object, target:String, tarId:String, ...args):int{
			target = target ? target+"."+tarId: tarId;
			var obj:* = ObjectUtils.getProperty( source, target );
			if( obj is Array ){
				return (obj as Array).length;
			}else{
				return 0;
			}
		}
		
		public static function pushToArrayProperty(obj:*, propName:String, value:*):Array {
			var arr:Array = obj[propName];
			if(!arr) {
				arr = obj[propName] = []
			}
			arr.push(value);
			return arr;
		}
		
	}
}
