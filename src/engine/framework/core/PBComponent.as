package engine.framework.core
{
    import engine.appHelper.GameApplication;
    import engine.framework.pb_internal;
    import engine.framework.property.PropertyManager;
    import engine.utils.AppUtils;
    
    use namespace pb_internal;
    
    /**
     * Base class for most game functionality. Contained in a PBGameObject.
     * 
     * Dependency injection is fulfilled based on the PBGroup containing the
     * owning PBGameObject.
     * 
     * Provides a generic data binding system as well as callbacks when
     * the component is added to or removed from a PBGameObject.
     */
    public class PBComponent
    {
		// for runtime debug
		[PBInject] public var gameapp:GameApplication;
		protected var _phase:String = null;
		protected function set phase(v:String):void{ _phase = v; }
		protected function get debugInfo():String{ return ""; }
		final protected function report(err:*):void
		{
			var where:String = _phase ? _phase:('doFrame' in this ? 'doFrame' : 'doTick');
			var msg:String = Object(this).constructor + "_" + where;
			msg += "\n" + (owner ? Object(owner).constructor : "[NoOwner]");
			msg += "\n" + debugInfo;
			if( err is Error )
			{
				msg += "\n" + (AppUtils.isDebugBuild() ? Error(err).getStackTrace() : Error(err).toString());
			}
			else
			{
				msg += "\n" + "[" + Object(err).constructor + "]" + err.toString();
			}
			gameapp.Global_Error.dispatch(msg);
		}
		// for runtime debug
        [PBInject]
        public var propertyManager:PropertyManager;
        
        protected var bindings:Vector.<String>;
        
        private var _safetyFlag:Boolean = false;
        private var _name:String;
        
        pb_internal var _owner:PBGameObject;
        
        public function get name():String
        {
            return _name;
        }
        
        /**
         * The name of the component. Can't be changed while it is registered
         * with an owning PBGameObject.
         */
        public function set name(value:String):void
        {
            if(_owner)
                throw new Error("Already added to PBGameObject, can't change name of PBComponent.");
            
            _name = value;
        }
        
        /**
         * What PBGameObject contains us, if any?
         */
        public function get owner():PBGameObject
        {
            return _owner;
        }
		
		/**
		 * This Component Require Which kind of components
		 * @return class array of the components
		 */
		protected function get requires():Array
		{
			return [];
		}
		
        /**
		 * @deprecated
		 * 
         * Components include a powerful data binding system. You can set up
         * rules indicating fields to load from other parts of the game, then
         * apply the data bindings using the applyBindings() method. If you don't
         * use them, bindings have no overhead.
         *  
         * @param fieldName Name of a field on this object to copy data to.
         * @param propertyReference A reference to a value on another component,
         *                          PBGameObject, or other part of the system.
         *                          Usually "@componentName.fieldName".
         */
        public function addBinding(fieldName:String, propertyReference:String):void
        {
            if(!bindings)
                bindings = new Vector.<String>();
            
            const binding:String = fieldName + "||" + propertyReference;
            
            bindings.push(binding);
        }
        
        /**
		 * @deprecated
		 * 
         * Remove a binding previously added with addBinding. Call with identical
         * parameters.
         */
        public function removeBinding(fieldName:String, propertyReference:String):void
        {
            if(!bindings)
                return;
            
            const binding:String = fieldName + "||" + propertyReference;
            var idx:int = bindings.indexOf(binding);
            if(idx == -1)
                return;
            bindings.splice(idx, 1);
        }
        
        /**
		 * @deprecated
		 * 
         * Loop through bindings added with addBinding and apply them. Typically
         * called at start of onTick or onFrame handler.
         */
        public function applyBindings():void
        {
            if(bindings == null)
                return;
            
            if(!propertyManager)
                throw new Error("Couldn't find a PropertyManager instance, is one available for injection?");
            
            for(var i:int=0; i<bindings.length; i++)
                propertyManager.applyBinding(this, bindings[i]);
        }
        
        pb_internal function doAdd():void
        {
            _safetyFlag = false;
			// Check requires and add required commponents
			var req:Array = this.requires, reqComp:PBComponent;
			if(req.length > 0){
				for each( var cls:Class in req){
					if(!(cls is PBComponent)) continue;
					if(this.owner.hasComponentByType(cls)) continue;
					
					reqComp = new cls;
					this.owner.addComponent(reqComp);
				}
			}
			// do on Add
            onAdd();
			if(_safetyFlag == false)
                throw new Error("You forget to call super.onAdd() in an onAdd override.");
        }
        
        pb_internal function doRemove():void
        {
            _safetyFlag = false;
            onRemove();
            if(_safetyFlag == false)
                throw new Error("You forget to call super.onRemove() in an onRemove handler.");
        }
        
        /**
         * Called when component is added to a PBGameObject. Do component setup
         * logic here.
         */
        protected function onAdd():void
        {
            _safetyFlag = true;
        }
        
        /**
         * Called when component is removed frmo a PBGameObject. Do component
         * teardown logic here.
         */
        protected function onRemove():void
        {
            _safetyFlag = true;
        }
    }
}