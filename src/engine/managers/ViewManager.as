package engine.managers
{
	import engine.framework.core.IPBManager;
	import engine.framework.debug.Logger;
	import engine.framework.util.TypeUtility;
	import engine.mvcs.EngineMediatorActivator;
	import engine.mvcs.EngineMediatorEvent;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * Game Views general manager
	 * @author Tang Bo Hao
	 */
	public class ViewManager implements IPBManager
	{	
		[PBInject] public var assetsMgr:AssetsManager;
		[PBInject] public var layerMgr:LayerManager;
		
		// the map of view and layers
		protected var _assignedViews:Dictionary = null;
		protected var _viewDomain:String;
		protected var _viewDic:Dictionary = null;
		
		// State Map
		protected var _stateStack:Vector.<XML>;
		protected var _viewStateInfo:XML;
		
		/**
		 * #inheritDoc
		 */
		public function initialize():void
		{
			this._assignedViews = new Dictionary(true);
			this._viewDic = new Dictionary(true);
			this._stateStack = new Vector.<XML>;
		}
		
		/**
		 * #inheritDoc
		 */
		public function destroy():void
		{
			this._assignedViews = null;
			this._viewDic = null;
			this._stateStack = null;
		}
		
		// ========== Public Functions ===============
		public function initViewManagerConfig(viewDomain:String, viewStateInfo:XML):void
		{
			this._viewDomain = viewDomain;
			this._viewStateInfo = viewStateInfo;
		}
		
		/**
		 * Register the view name to a layer
		 * @param name view's class name
		 * @param layerName layer's name
		 */
		public function assignView(name:String, layerName:String):void
		{
			this._assignedViews[name] = layerName;
		}
		
		// ==! ====== View State Functions ===========
		/**
		 * Push a view state
		 * @param stateName
		 */
		public function pushViewState(stateName:String, initData:* ):void
		{
			if(!this._viewStateInfo) return;
			
			// to find the view state
			var states:XMLList = this._viewStateInfo.state.(@name==stateName);
			var targetState:XML = states.copy()[0];
			
			if(!targetState){
				targetState = <state name={stateName}><view name={stateName} /></state>;
			}
			
			this.deactiveTopState();
			this._stateStack.push(targetState);
			this.executeState(targetState, true, initData);
		}
		
		/**
		 * pop the top view state
		 */
		public function popViewState():String
		{
			var targetState:XML;
			if(this._stateStack.length>0){
				targetState = this._stateStack[_stateStack.length-1];
				this.executeState(targetState, false);
				this._stateStack.pop();
				this.activeTopState();
				return targetState.@name;
			}
			return null;
		}
		
		/**
		 * Do the push and pop stuffs
		 */
		private function executeState(stateInfo:XML, isEnter:Boolean, initData:* = null):void
		{
			var stateViews:XMLList = stateInfo.children(),
				view:XML;
			if(isEnter){
				for each(view in stateViews){
					this.addView(view.@name, "", initData);
				}
			}else{
				
				for each(view in stateViews){
					this.removeView(view.@name);
				}
			}
		}
		
		/**
		 * Getter for top state name
		 * @return String
		 */
		public function get topStateName():String
		{
			if(_stateStack.length>0){
				return _stateStack[_stateStack.length - 1].@name;
			}
			return null;
		}
		
		public function raiseState(name:String):void
		{
			var target:XML = null, 
				i:int = 0,
				len:int = _stateStack.length;
			for(; i < len ; i++){
				if(_stateStack[i].@name == name){
					target = _stateStack[i];
					break;
				}
			}
			
			if(target){
				this.deactiveTopState();
				this._stateStack.splice(i, 1);
				this._stateStack.push(target);
				this.activeTopState();
			}
		}
		
		private function deactiveTopState():void
		{
			if(this.topStateName){
				var stateViews:XMLList  = _stateStack[_stateStack.length - 1].children();
				var view:Sprite;
				for each(var viewInfo:XML in stateViews){
					view = this._viewDic[viewInfo.@name.toString()];
					if(view) view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_DEACTIVATED, view));
				}
			}
		}
		
		private function activeTopState():void
		{
			if(this.topStateName){
				var stateViews:XMLList  = _stateStack[_stateStack.length - 1].children();
				var view:Sprite;
				for each(var viewInfo:XML in stateViews){
					view = this._viewDic[viewInfo.@name.toString()];
					if(view) view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_ACTIVATED, view));
				}
			}
		}
		
		// ====! ======== Basic View functions =====
		/**
		 * push a view to stage
		 * @param name String the view name
		 * @param keyPrefix
		 * @param viewDomain
		 * @return the key when used in removeView
		 */
		public function addView(name:String, keyPrefix:String = "", initData:* = null ):Sprite
		{
			var viewDomain:String = this._viewDomain;
			if(!viewDomain) return null;
			
			// the view class
			var viewClass:Class;			
			try{
				viewClass = assetsMgr.getClass(viewDomain, name);
			}catch(e:Error){
				Logger.error(this,"pushView", e.message);
				// TODO
				throw e;
			}
			
			// create and add view
			var view:Sprite = new viewClass;
			var layername:String = this._assignedViews[name];
			// using EngineMediatorActivator to activate view Mediator, this should only used for one time
			new EngineMediatorActivator(view, initData ,true);
			layerMgr.addViewToLayer(view, layername);
			
			this._viewDic[keyPrefix + name] = view;
			
			return view;
		}
		
		/**
		 * pop the top view in the stack
		 * @return DisplayObjectContainer
		 */
		public function removeView(name:String, keyPrefix:String = ""):Sprite
		{
			var view:Sprite = this._viewDic[keyPrefix + name];
			if(!view) return null;
			
			var layername:String = this._assignedViews[TypeUtility.getObjectClassName(view)];
			layerMgr.removeViewFromLayer(view, layername);
			delete this._viewDic[keyPrefix + name];
			
			return view;
		}
		
		/**
		 * Get a view by name
		 * @param name
		 * @return
		 */
		public function getViewByKey(key:String):Sprite
		{
			return this._viewDic[key];
		}
		
		// ==! ====== Accessors ===========
		/**
		 * Get current stateStack
		 * @return 
		 */
		public function get stateStack():Vector.<XML>
		{
			return this._stateStack;
		}
	}
}