package engine.framework.core
{
    import engine.framework.PBE;
    import engine.framework.pb_internal;
    import engine.framework.util.Injector;
    import engine.framework.util.TypeUtility;
    
    import flash.utils.getQualifiedClassName;
    
    use namespace pb_internal;
    
    /**
     * PBGroup provides lifecycle functionality (PBObjects in it are destroy()ed
     * when it is destroy()ed), as well as dependency injection (see
     * registerManager).
     * 
     * PBGroups are unique because they don't require an owningGroup to 
     * be initialize()ed.
     */
    public class PBGroup extends PBObject
    {
        protected var _items:Vector.<PBObject> = new Vector.<PBObject>();
        protected var _injector:Injector = null;
        
        public function PBGroup(_name:String = null)
        {
            super(_name);
        }
        
        pb_internal function get injector():Injector
        {
            if(_injector)
                return _injector;
            else if(owningGroup)
                return owningGroup.injector;
            return null;
        }
        
        /**
         * Does this PBGroup directly contain the specified object?
         */
        public final function contains(object:PBObject):Boolean
        {
            return (object.owningGroup == this);
        }
        
        /**
         * How many PBObjects are in this group?
         */
        public final function get length():int
        {
            return _items.length;
        }
        
        /**
         * Return the PBObject at the specified index.
         */
        public final function getPBObjectAt(index:int):PBObject
        {
            return _items[index];
        }
        
        public override function initialize():void
        {
            // Groups can stand alone so don't do the _owningGroup check in the parent class.
            //super.initialize();
            
            // If no owning group, add to the global list for debug purposes.
            if(owningGroup == null)
            {
                owningGroup = PBE._rootGroup;
            }
            else
            {
                if(_injector)
                    _injector.setParentInjector(owningGroup.injector);
                
                owningGroup.injectInto(this);                
            }
        }
        
        public override function destroy():void
        {
            super.destroy();
			
			// clear cache
			_cacheLookupGOs = null;
            
            // Wipe the items.
            while(length)
                getPBObjectAt(length-1).destroy();
            
			// Shut down the managers we own.
            if(_injector)
            {
                for(var key:* in _injector.mappedValues)
                {
                    const val:* = _injector.mappedValues[key];
                    if(val is IPBManager)
                        (val as IPBManager).destroy();
                }
			}
			
        }
        
        pb_internal function noteRemove(object:PBObject):void
        {
            // Get it out of the list.
            var idx:int = _items.indexOf(object);
            if(idx == -1)
                throw new Error("Can't find PBObject in PBGroup! Inconsistent group membership!");
            _items.splice(idx, 1);
        }
        
        pb_internal function noteAdd(object:PBObject):void
        {
            _items.push(object);
        }
        
        //---------------------------------------------------------------
        
        protected function initInjection():void
        {
            if(_injector)
                return;
            
            _injector = new Injector();
            
            if(owningGroup)
                _injector.setParentInjector(owningGroup.injector);
        }
        
        /**
         * Add a manager, which is used to fulfill dependencies for the specified
         * clazz. If the "manager" implements the IPBManager interface, then
         * initialize() is called at this time. When the PBGroup's destroy()
         * method is called, then destroy() is called on the manager if it
         * implements IPBManager. Injection is also done on the manager when it
         * is registered.
         */
        public function registerManager(clazz:Class, instance:*):void
        {
            initInjection();
            _injector.mapValue(instance, clazz);
            _injector.apply(instance);
            
            if(instance is IPBManager)
                (instance as IPBManager).initialize();
        }
        
        /**
         * Get a previously registered manager.
         */
        public function getManager(clazz:Class):*
        {
            var res:* = null;
            
            res = injector.getMapping(clazz);
            
            if(!res)
                throw new Error("Can't find manager " + clazz + "!");
            
            return res;
        }
        
        /**
         * Perform dependency injection on the specified object using this 
         * PBGroup's injection mappings. 
         */
        public function injectInto(object:*):void
        {
            injector.apply(object);
        }
        
		/**
		 * Lookup By Name, only return the first found
		 * @param name
		 * @return 
		 */
        public function lookupByName(name:String):PBObject
        {
			var ret:PBObject;
			var i:int, n:int;
			for( i = 0, n = _items.length; i < n; ++i )
			{
				if( _items[i].name == name ){
					ret = _items[i];
					break;
				}
			}
            return ret;
        }
		
		/**
		 * Look up game objects by type selector
		 * although result is a vector it is unordered
		 * you can NOT depend the sort of elements
		 * 
		 * @example
		 * lookupGameObjects() // return all game objects in the group
		 * lookupGameObjects( MyComponent ) // return all game objects that has the MyComponent in the group
		 * lookupGameObjects( Render, Physics, AI ) // return all game objects that has Render and Physics and AI in the group
		 * (deprecated) lookupGameObjects( Render, Physics, AI, "or" ) // return all game objects that has at least one of those compoents
		 * 
		 * @param types
		 * @return a list of game objects
		 * @throw ArgumentError
		 * 
		 */
		public function lookupGameObjects(...types):Vector.<PBGameObject>
		{
			var key:String = convertTypes( types );
			if(!_cacheLookupGOs) _cacheLookupGOs = {};
			if(_cacheLookupGOs[ key ]) return _cacheLookupGOs[ key ];
			return _cacheLookupGOs[ key ] = __lookupGameObjects.apply(this, types);;
		}
		
		pb_internal function removeFromLookupCache(object:PBGameObject):void
		{	
			for(var key:String in _cacheLookupGOs){
				var classes:Array = key.split(",");
				var hasKey:Boolean = true;
				for(var i:int = classes.length - 1; i > -1; --i){
					var cls:Class = TypeUtility.getClassFromName(classes[i]);
					if(! PBGameObject(object).hasComponentByType(cls) ){
						hasKey = false;
						break;
					}
				}
				if(hasKey){
					var gos:Vector.<PBGameObject> = _cacheLookupGOs[key];
					var index:int = gos.indexOf(object);
					if(index>-1){
						gos[index] = gos[gos.length-1];
						--gos.length;
//						gos.splice(index, 1);
					}
					
					if(gos.length == 0){
						delete _cacheLookupGOs[key];
					}
				}
			}
		}
		
		pb_internal function addToLookupCache(object:PBGameObject):void
		{
			for(var key:String in _cacheLookupGOs){
				var classes:Array = key.split(",");
				var hasKey:Boolean = true;
				for(var i:int = classes.length - 1; i > -1; --i){
					var cls:Class = TypeUtility.getClassFromName(classes[i]);
					if(! PBGameObject(object).hasComponentByType(cls) ){
						hasKey = false;
						break;
					}
				}
				if(hasKey){
					_cacheLookupGOs[key].push(object);
				}
			}
		}
		private var _cacheLookupGOs:Object;
		private function __lookupGameObjects(...types):Vector.<PBGameObject>
		{
			var i:int, n:int;
			var result:Vector.<PBGameObject> = new Vector.<PBGameObject>();
			
			// invalid arguments
			if( 1 == types.length && !(types[0] is Class) ) throw new ArgumentError("Error: invalid arguments");
			
			// retrieve all game objects
			var all:Vector.<PBGameObject> = new Vector.<PBGameObject>();
			for( i = 0, n = _items.length; i < n; ++i )
			{
				if( _items[i] is PBGameObject )
				{
					all.push( _items[i] );
				}
			}
			
			// look up all
			if( 0 == types.length ) return all;
			
			// look up by filters
			var looked:Boolean;
			var j:int;
			
			for( i = 0, n = all.length; i < n; ++i )
			{
				for( j = types.length - 1; j > -1; --j)
				{
					looked = all[i].hasComponentByType( types[j] );
					if(!looked) break;
				}
				if(looked) result.push( all[i] );
			}
			return result;
		}
		
		/**
		 * @private
		 * 
		 * convert types to sort string for cache key
		 * @param types
		 * @return 
		 */
		private function convertTypes(types:Array):String
		{
			var t:Array = [];
			for(var i:int = types.length - 1; i > -1; --i)
				t[i] = getQualifiedClassName( types[i] );
			t.sort();
			return t.join(",");
		}
    }
}