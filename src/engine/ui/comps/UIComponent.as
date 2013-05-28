package engine.ui.comps
{	
	import flash.display.InteractiveObject;
	import flash.utils.Dictionary;
	
	import engine.framework.core.IPBManager;
	import engine.framework.util.TypeUtility;
	import engine.tween.TweenManager;
	import engine.ui.decorators.ColorDecorator;
	import engine.utils.ObjectUtils;
	
	import org.osflash.signals.Signal;

	/**
	 * Base Interative UI class
	 * @author Tang Bo Hao
	 */
	public class UIComponent implements IPBManager
	{
		// Injection 
		[PBInject] public var tweenMgr:TweenManager;
		
		// constant
		public static const DEFAULT_TWEENTIME:Number = 0.4;
		
		// protected variables
		protected var _compID:String = ""; //component name
		protected var _path:String = ""; //component owner path
		protected var _className:String = "";
		protected var _display:InteractiveObject = null; // current display
		protected var _owner:UIComponent = null;
		protected var _children:Vector.<UIComponent> = null; // children items
		protected var _childrenMap:Dictionary = null;
		
		// State variables
		protected var _activate:Boolean;
		
		// display variables
		private var _isGray:Boolean;
		private var _isHighLight:Boolean = false;
		private var _hightLightWhenActivate:Boolean;
		protected var _colorDeco:ColorDecorator;
		
		// Component Data
		protected var _linkedClass:Class = null;
		protected var _linkedProperty:String = null;
		protected var _linkedData:*;
		private var _value:*;
		
		// Signal
		protected var _onDeactivated:Signal;
		protected var _onActivated:Signal;
		protected var _mapFunc:Function;
		protected var _useClassName:Boolean = true;
		
		/**
		 * Constructer, give a display and childReg to generate children UIInteractive
		 * @param id name of the component
		 * @param display the display view of the component
		 * @param owner the owner
		 */
		public function UIComponent(id:String, display:InteractiveObject, owner:UIComponent)
		{
			this._compID = id;
			this._display = display;
			
			if(owner){
				// Update UIComponent Path as Class Name
				var disClassName:String = TypeUtility.getObjectClassName( display );
				if( disClassName.indexOf('.') == -1 ){ // special class exported in FLA
					this._className = disClassName;
				}
				// the path of the component
				this._path = owner.path ? owner.fullName : owner.name;
				
				this._owner = owner;
				this._owner.addChild(this);
			}
			
		}
		
		public function initialize():void
		{
			// Nothing Now
		}
		
		/**
		 * Dispose all ui
		 */
		public function destroy():void
		{
			clearChildren();
			
			this._colorDeco = null;
			this._linkedClass = null;
			this._linkedProperty = null;
			this._linkedData = null
			
			// clear display
			this._display = null;
			
			// Clear Signals
			clearSignal(_onActivated);
			clearSignal(_onDeactivated);
		}
		
		/**
		 * Easy Way to clear Component Children
		 */
		public function clearChildren():void
		{
			if(this._children){
				// children dispose
				for each(var item:UIComponent in _children){
					item.destroy();
					delete this._childrenMap[item.name];
				}	
			}
			this._children = null;
			this._childrenMap = null
		}
		
		/**
		 * Easy Wat to disable Click
		 */
		public function disableClick():void
		{
			if( this._children ) {
				// search for uiinteractive
				for each(var item:UIComponent in _children){
					if( item is UIInteractive ) item.disableClick();
				}	
			}
		}
		
		/**
		 * add a child to this
		 * @param child
		 */
		protected function addChild(child:UIComponent):void
		{
			if(!_children){
				_children = new Vector.<UIComponent>;
				_childrenMap = new Dictionary;
			}
			_children.push(child);
			_childrenMap[child.name] = child;
		}
		
		/**
		 * Remove a child from this
		 * @param child
		 */
		public function removeChild( child:UIComponent ):void{
			if( !children || children.length == 0 ) return;
			
			if( _childrenMap[child.name] ){
				delete _childrenMap[child.name];
				_children.splice(_children.indexOf( child ), 1 );
			}
		}
		
		/**
		 * Find the child by name
		 * @param name
		 * @return
		 */
		public function getChildByName(name:String):UIComponent
		{
			if(!_childrenMap)	return null;
			else{
				var nameArr:Array = name.split(".");
				var currentUI:UIComponent = this;
				while( nameArr.length > 0 ){
					name = nameArr.shift();
					currentUI = currentUI._childrenMap[name];
					if( !currentUI ) return null;
				}
				return currentUI;
			}
		}
		
		public final function get value():* {
			return this._value;
		}
		
		public final function set value(v:*):void {
			if( v != v) v = null;
			this._value = v;
			updateValue();
		}
		
		protected function updateValue():void {
			throw new Error((typeof this) + " Not implement updateValue");
		}

		/**
		 * update component's data
		 * should be implemented in child class
		 * @param data
		 */
		public function updateData(data:*):void{
			// Default to set data as Value
			// also will run mapFunc
			this._value = getLinkedProperty(data);
			
			if(this._children && this.visible ){
				for each(var child:UIComponent in this._children){
					child.updateData(data);
				}
			}
		}
		
		/**
		 * Register this component to some class
		 * @param clsName
		 * @param propName
		 */
		public function linkProperty(cls:Class, propName:String = ""):UIComponent
		{
			this._linkedClass = cls;//TypeUtility.getObjectClassName(cls);
			this._linkedProperty = propName;
			return this;
		}
		
		public function map(mapFunc:Function):UIComponent
		{
			this._mapFunc = mapFunc;
			return this;
		}
		
		public function linkChildProperty(child:String, cls:Class, propName:String = ""):UIComponent
		{
			var childUI:UIComponent = this.getChildByName(child);
			if(childUI) {
				childUI.linkProperty(cls, propName);
			}
			return this;
		}
		
		public function mapChild(child:String, mapFunc:Function):UIComponent
		{
			var childUI:UIComponent = this.getChildByName(child);
			if(childUI) {
				childUI.map(mapFunc);
			}
			return this;
		}
		
		// Signal Accessors
		
		public function get onActivated():Signal {
			return _onActivated ||= new Signal();
		}
		
		public function get onDeactivated():Signal {
			return _onDeactivated ||= new Signal();
		}
		
		public function set activated(value:Boolean):void{
			if(_activate == value ) return;
			
			if( value ){
				if(hightLightWhenActivated)
					this.isHighLight = true;
				this.onActivated.dispatch();
			}else{
				if(hightLightWhenActivated)
					this.isHighLight = false;
				this.onDeactivated.dispatch();
			}
			
			this._activate = value;
		}
		public function get activated():Boolean {	return this._activate;	}
		
		// ==! ==== protected =====
		/**
		 * get registered property in the given data 
		 * @param data
		 */
		protected function getLinkedProperty(data:*):*{
			// Set to linked data first
			this._linkedData = data;
			
			var datavalue:*;
			if(validateData(data) && this._linkedProperty) {
				datavalue = ObjectUtils.getProperty(data, this._linkedProperty);
			}else{
				datavalue = data;
			}
			
			return (_mapFunc != null) ? _mapFunc.call(this, datavalue) : datavalue;
		}
		
		/**
		 * set registered property in the given data 
		 * @param data
		 * @param value
		 */
		protected function setLinkedProperty(value:*):void{
			if(this._linkedData == null) return;
			if(!validateData(this._linkedData)) return;
			
			ObjectUtils.setProperty(this._linkedData, this._linkedProperty, value);
		}
			
		/**
		 * To check the data
		 * @param data
		 * @return 
		 */
		private function validateData(data:*):Boolean{
			// 2012/11/15 Using Class to avoid deep inherted Object can not be not validated  
			return data != null && ( _linkedClass && data is _linkedClass); 
//				( this._linkedClass == flash.utils.getQualifiedClassName(data)
//				|| this._linkedClass == flash.utils.getQualifiedSuperclassName(data) );
		}
		
		// ==! ==== Getter and Setter =====
		/**
		 * set display as gray
		 * @param gray
		 */
		public function set isGray(gray:Boolean):void{
			var old:Boolean = this._isGray;
			if(old == gray) return;
			
			if (!old){ // false to gray
				tweenMgr.add(this.content, { alpha:0.7 }, { time: this.colorEffect.delay } );
				tweenMgr.add(this.colorEffect, { saturation:0.3 }, { time: this.colorEffect.delay } );
			} else { // true to no gray
				tweenMgr.add(this.content, { alpha:1 }, { time: this.colorEffect.delay } );
				tweenMgr.add(this.colorEffect, { saturation:1 }, { time: this.colorEffect.delay } );
			};
			this._isGray = gray;
		}
		public function get isGray():Boolean	{ return this._isGray; }
		
		public function set hightLightWhenActivated( value:Boolean ):void {	this._hightLightWhenActivate = value; }
		public function get hightLightWhenActivated():Boolean { return this._hightLightWhenActivate; }
		
		/**
		 * High Light Effect
		 * @param value
		 */
		public function set isHighLight( value:Boolean ):void{
			if(_isHighLight == value) return;
			
			if (value){ // true to highlight
				tweenMgr.add(this.colorEffect, { brightness:0.2 }, { time: this.colorEffect.delay } );
			} else { // false to normal
				tweenMgr.add(this.colorEffect, { brightness:0 }, { time: this.colorEffect.delay } );
			};
			this._isHighLight = value;
		}
		public function get isHighLight():Boolean { return this._isHighLight; } 
		
		public function get colorEffect():ColorDecorator {	return this._colorDeco ||= new ColorDecorator(this._display); }
		
		/**
		 * Get the components children
		 * @return all components children 
		 */
		public function get children():Vector.<UIComponent>
		{
			return this._children;
		}
		
		public function get linkedData():* { return this._linkedData; }
		public function set linkedData( d:* ):void {	this._linkedData = d; }
		
		public function get name():String { return this._compID; }
		
		public function get path():String { return this._path; }
		
		public function set useClassName(v:Boolean):void { _useClassName = v; }
		public function get useClassName():Boolean { return _useClassName; }
		
		public function get fullName():String
		{
			if(_useClassName && _className)
				return _className;
			
			if(path)
				return path + "." + name;
			
			return name;
		}
		
		public function get content():InteractiveObject { return this._display }
		
		public function get visible():Boolean { return content.visible }
		
		public function set visible(visibility:Boolean):void { content.visible = visibility }
		
		// >> ============ Utility Functions =========== << 
		/**
		 * Util function to log the ui tree
		 * @param comp
		 * @param result
		 * @param indent
		 */
		public static function treeLog(comp:UIComponent, result:Array, indent:int = 0):void {
			var indentStr:String = '';
			for(var i:int = 0; i < indent; i++) {
				indentStr += ' ';
			}
			indentStr += '|- ';
			if(comp == null) {
				result.push( indentStr + 'null' );
				return;
			}
			if(comp._childrenMap) {
				for(var name:String in comp._childrenMap) {
					result.push(indentStr + name + '      <' + comp._childrenMap[name].constructor + '>');
					treeLog(comp._childrenMap[name], result, indent + 2);
				}
			}
		}
		
		public function treeLog():String {
			var result:Array = new Array;
			UIComponent.treeLog(this, result, 0);
			return "component tree \n" + result.join("\n");
		}
		
		/**
		 * Util function to clear one signal;
		 */
		protected function clearSignal(sig:Signal):void
		{
			if(sig) sig.removeAll();
		}
		
	}
}
