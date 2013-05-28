package engine.ui.comps
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * A UI Component with some state
	 * @author Tang Bo Hao
	 */
	public class UIStateComponent extends UIInteractive
	{	
		public static const STATE_DISABLE:String = "disable";
		
		protected var _mappedStates:Dictionary;
		protected var _defaultStateData:*;
		private var _currentState:MappedState;
		
		public function UIStateComponent(id:String, display:Sprite, owner:UIComponent)
		{	
			super(id, display, owner);
			
			_mappedStates = new Dictionary(false);
			this.display.mouseChildren = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			_mappedStates = null;
			_defaultStateData = null;
			
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateData(data:*):void
		{
			this.value = this.getLinkedProperty(data);
			// Update current state data and non-stated ui
			if(this._children && this.visible ){
				for each(var child:UIComponent in this._children){
					if( child.content.parent )
						child.updateData(data);
				}
			}
		}
		
		override protected function updateValue():void
		{
			var currentData:* = this.value;
			var state:MappedState;
			if( currentData == null){
				state = this._mappedStates[ STATE_DISABLE ];
			}else{
				state = this._mappedStates[ currentData.toString() ] || this._mappedStates[ this._defaultStateData ];
			}
			
			// State is diffrent, chaneg the state
			if(state != this._currentState) {
				// to change state, first remove the old one
				if(this._currentState){
					this._currentState.displayParent.removeChild(this._currentState.target.content);
				}
				// set new state
				if(state){
					state.displayParent.addChild(state.target.content);
				}
				this._currentState = state;
			}
			
		}
		
		/**
		 * Current UIComponent
		 * @return
		 */
		public function get currentStateUI():UIComponent{
			if( _currentState )
				return this._currentState.target;
			else
				return null;
		}
		
		/**
		 * when data or linked data is equal to the value, the display MC will goto the target state Label and  
		 * @param value
		 * @param stateLabel
		 */
		public function mapState(value:*, childName:String, isDefault:Boolean = false):UIStateComponent
		{
			var child:UIComponent = this.getChildByName(childName);
			if(child){
				var mapKey:String = value.toString();
				var mappedState:MappedState = new MappedState;
				mappedState.displayParent = child.content.parent;
				mappedState.stateKeyData = mapKey;
				mappedState.target = child;
				
				// store the state
				_mappedStates[ mapKey ] = mappedState;
				
				// check and set state
				if(isDefault) this._defaultStateData = mapKey;
				
				// remove the display from its' parent
				if(child.content && child.content.parent) {
					child.content.parent.removeChild( child.content);
				}
			}
			return this;
		}
		
		/**
		 * Auto Map Child State
		 * @return
		 */
		public function autoMapState():UIStateComponent
		{
			this.children.forEach(function( child:UIComponent, ...args):void{
				this.mapState(child.name, child.name);
			}, this);
			return this;
		}
		
		// >> Accessor <<
		
	}
}

import engine.ui.comps.UIComponent;

import flash.display.DisplayObjectContainer;

class MappedState{
	public var stateKeyData:String;
	public var displayParent:DisplayObjectContainer;
	public var target:UIComponent;
}