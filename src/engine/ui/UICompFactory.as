package engine.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.utils.Dictionary;
	
	import engine.EngineContext;
	import engine.framework.core.IPBManager;
	import engine.framework.debug.Logger;
	import engine.ui.comps.UIBaseButton;
	import engine.ui.comps.UIComponent;
	import engine.ui.comps.UIEmbedIconLoader;
	import engine.ui.comps.UIFxComponent;
	import engine.ui.comps.UIIconLoader;
	import engine.ui.comps.UIInteractive;
	import engine.ui.comps.UIMovieClip;
	import engine.ui.comps.UISelectButton;
	import engine.ui.comps.UIStateComponent;
	import engine.ui.comps.UITextField;
	import engine.ui.container.UIGridBox;
	import engine.ui.container.UIListBox;

	/**
	 * The UI component factory
	 * @author Tang Bo Hao
	 */
	public class UICompFactory implements IPBManager
	{	
		// >> Constant <<
		protected const IGNORE_REG:RegExp = /^\$ignore\$.*/i;
		
		// >> Injection <<
		[PBInject] public var engineCxt:EngineContext;
		
		/* ==!====== Class Defination ======== */
		private var _factoryInteractiveClasses:Dictionary;// factory classes lib
		private var _displayCache:Dictionary;
		
		/**
		 * class constructor
		 */
		public function initialize():void
		{
			this._factoryInteractiveClasses = new Dictionary;
			this._displayCache = new Dictionary;
			
			// ------ Register Default RegExps ---------
			//register UI regExp
			this.registerFactory( /^\$base\$(\w*[^\$])(?=\$\$)/i, UIComponent);
			this.registerFactory( /^\$mc\$(\w*[^\$])(?=\$\$)/i, UIMovieClip);
			// Interactive UI
			this.registerFactory( /^\$interactive\$(\w*[^\$])(?=\$\$)/i, UIInteractive);
			this.registerFactory( /^\$interactivePNG\$(\w*[^\$])(?=\$\$)/i, UIInteractive);
			this.registerFactory( /^\$btn\$(\w*[^\$])(?=\$\$)/i, UIBaseButton);
			this.registerFactory( /^\$sbtn\$(\w*[^\$])(?=\$\$)/i, UISelectButton);
			// Icons
			this.registerFactory( /^\$icon\$(\w*[^\$])(?=\$\$)/i, UIIconLoader);
			this.registerFactory( /^\$eicon\$(\w*[^\$])(?=\$\$)/i, UIEmbedIconLoader);
			// Conditional 
			this.registerFactory( /^\$state\$(\w*[^\$])(?=\$\$)/i, UIStateComponent);
			// FX comp
			this.registerFactory( /^\$fx\$(\w*[^\$])(?=\$\$)/i, UIFxComponent);
			
			// register Containers regExp
			this.registerFactory( /^\$list\$(\w*[^\$])(?=\$\$)/i, UIListBox);
			this.registerFactory( /^\$gridbox\$(\w*[^\$])(?=\$\$)/i, UIGridBox);
			
			//register TextField regExp
			this.registerFactory( /^\$tf\$(\w*[^\$])(?=\$\$)/i, UITextField);
		}
		
		/**
		 * class destructor
		 */
		public function destroy():void
		{
			this._factoryInteractiveClasses = null;
			this._displayCache = null;
		}
		
		/**
		 * RegExp is used to match instance
		 * @param reg a regExp to match factory class
		 * @param cls instanceof UIInteractive
		 * @param register to check children
		 */
		public function registerFactory(reg:RegExp, cls:Class):void
		{
			this._factoryInteractiveClasses[reg] = cls;
		}
		
		/**
		 * Create a UIInteractive by registered Reg
		 * @param display
		 * @param owner ui owner
		 * @return an instance of Factory Class, if not match return null
		 */
		public function createUI(display:InteractiveObject, owner:UIComponent = null):UIComponent
		{
			var uiRet:UIComponent = null, name:String = display.name,
				cls:Class, superClass:String;
			var cachedName:String = (owner ? owner.name+"_" :"default_") + display.name;
			
			// IGNORE paticular MovieClips 
			if( IGNORE_REG.test(name) )
				return null;
			
			// Create UI Component for matched MovieClips
			if(name.charAt(0) == "$"){
				// test all keys
				for( var key:* in _factoryInteractiveClasses)
				{
					if(key.test(name)) // test passes then return
					{
						cls = Class(_factoryInteractiveClasses[key]);
						try{
							uiRet = new cls( (name.match(key))[1], display, owner);
						}catch(err:Error){
							Logger.error(this, 'createUI', err.message);
						}
						
						engineCxt.injectInto(uiRet);
						uiRet.initialize();
						break;
					}
				}	
			}
			
			if(display is DisplayObjectContainer){
				var cachePathVec:Vector.<String> = this._displayCache[cachedName];
				try{
				// using cached data and return
				if(uiRet && cachePathVec){
					for each( var path:String in cachePathVec ){
						const indexs:Array = path.split("_");

						var currDisplay:DisplayObject = display;
						while(indexs[0] != "$"){
							currDisplay = DisplayObjectContainer(currDisplay).getChildAt(int(indexs.shift()));
						}
						this.createUI(currDisplay as InteractiveObject, uiRet);
					}
					return uiRet;
				}
				}catch(e:*) {
					Logger.error(this, 'createUI', 'error to create UI for :' + cachedName);
				}
				
				// search all children to create ui
				var len:uint = DisplayObjectContainer(display).numChildren;
				var child:DisplayObject;
				for(var i:uint = 0; i< len; i++){
					child = DisplayObjectContainer(display).getChildAt(i);
					if(!(child is InteractiveObject)) continue;
					
					this.createUI(child as InteractiveObject, uiRet || owner);
				}
				
				// cache the path
				if(uiRet){
					cachePathVec = new Vector.<String>;
					if(uiRet.children){
						uiRet.children.forEach(function(child:UIComponent,...rest):void{
							var curr:InteractiveObject = child.content;
							var childIndex:String = "$";
							while(curr.parent != uiRet.content){
								childIndex = String(curr.parent.getChildIndex(curr)) + "_" +childIndex;
								curr = curr.parent;
							}
							childIndex = DisplayObjectContainer(uiRet.content).getChildIndex(curr) + "_" + childIndex;
							cachePathVec.push(childIndex);
						});	
					}
					this._displayCache[cachedName] = cachePathVec;
				}
			}
			
			return uiRet;
		}
	}
}