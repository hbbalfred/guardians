package engine.utils
{
	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	/**
	 * A key/value local storage for runtime usage
	 * using sharedobject or memory 
	 * @author Tang Bo Hao
	 * 
	 */
	public class LocalStorage
	{
		// Static variables
		protected static var _instance:LocalStorage;
		protected static var _safeFlag:Boolean;
		protected static var _userId:String = "";
		
		/**
		 * @desc	instance getter of class LocalStorage
		 * @return singleton instance of LocalStorage 
		 */
		static protected function get instance():LocalStorage
		{
			if ( _instance == null )
			{
				_safeFlag = true;
				_instance = new LocalStorage();
				_safeFlag = false;
			}
			return _instance;
		}
		
		/**
		 * static function for setting object to localstorage 
		 * @param key Object key
		 * @param value Object 
		 */
		static public function setValue(key:String, value:* ):void
		{
			LocalStorage.instance.setValue(key,value);
		}
		
		/**
		 * static function for getting a object from localstorage
		 * @param key Object key
		 * @return Object
		 */
		static public function getValue(key:String):*
		{
			return LocalStorage.instance.getValue(key);
		}
		
		/**
		 * static function for remove a object from localstorage 
		 * @param key Object key
		 * @return the removed Object
		 * 
		 */
		static public function remove(key:String):*
		{
			return LocalStorage.instance.remove(key);
		}
		
		public static function reset( userId:String ):void
		{
			_userId = userId;
			LocalStorage.instance.reset();
		}
		
		/* ==!====== Class Defination ======== */
		protected var _soEnabled:Boolean = true;
		protected var _so:SharedObject = null;
		protected var _memoryStorage:Dictionary = null;
		
		public function LocalStorage() 
		{
			if ( _safeFlag == false )	throw Error( "[Error] LocalStorage is a singleton, can not be created directly" );
			
			reset();
			// always create a memory storage
			_memoryStorage = new Dictionary;
		}
		
		protected function reset():void
		{
			// Test SharedObject
			try{
				_so = SharedObject.getLocal( LocalStorage._userId + "LocalStorage");
				_soEnabled = true;
			}catch(error:Error)
			{
				_so = null;
				_soEnabled = false;
			}
		}
		
		protected function setValue(key:String, value:* ):void
		{
			if(this._soEnabled){
				this._so.data[key] = value;
				this._so.flush();
			}else{
				this._memoryStorage[key] = value;
			}
		}
		
		protected function getValue(key:String):*
		{
			// check so
			if(this._soEnabled){
				var value:* = this._so.data[key];
				if(value) return value;
			}
			// get from memory
			return this._memoryStorage[key];
		}
		
		protected function remove(key:String):*
		{
			var value:*;
			// check so 
			if(this._soEnabled){
				value = this._so.data[key];
				if(value){
					delete this._so.data[key];
					return value;
				}
			}
			// if doesn't exist in so, check memory
			value = this._memoryStorage[key];
			if(value){
				delete this._memoryStorage[key];
			}
			
			return value;
		}
	}
}