package engine.ui.comps
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * A type of button can hold select status
	 * @author Tang Bo Hao
	 */
	public class UISelectButton extends UIBaseButton
	{
		// constant
		protected static const GROUPNAME_RegExp:RegExp = /.+\$\$G\$(\w+)\$/i;
		private static var c_groups:Dictionary = new Dictionary;
		
		// class variables
		protected var _selected:Boolean = false; // if this button is selected button (default UP)
		protected var _groupName:String = null; // select group name
		
		public function UISelectButton(id:String, display:MovieClip, owner:UIComponent)
		{
			super(id, display, owner);
			
			// set group name
			var gname:Array = display.name.match(GROUPNAME_RegExp);
			if(gname && gname[1]){
				this._groupName = gname[1];
			}else{
				this._groupName = 'default';
			}
			
			// set to group
			if(!c_groups[_groupName]){// create a group, if not exist
				c_groups[_groupName] = new Vector.<UISelectButton>;
			}
			Vector.<UISelectButton>(c_groups[_groupName]).push(this);
			
			this._selected = false;
		}
		
		override public function destroy():void
		{
			//remove from group
			var group:Vector.<UISelectButton> = Vector.<UISelectButton>(c_groups[_groupName]);
			group.splice(group.indexOf(this), 1);
			
			if(group.length == 0) c_groups[_groupName] = null;
			
			super.destroy();
		}
		
		/**
		 * Set if the button is selected
		 * @param value
		 */
		public function set selected(value:Boolean):void
		{
			if (this.selected == value) return;
			
			if (value){ // set to selected
				this.buttonStatus = STATUS_DOWN;
				this.disableMouseListeners();
				
				// set the others to unselect
				Vector.<UISelectButton>(c_groups[_groupName])
				.forEach(function(sbtn:UISelectButton, ...rest):void{
					if(sbtn != this){ // unselect not this
						sbtn.selected = false;
					}
				}, this);
			}else { // set to unselected
				this.buttonStatus = STATUS_UP;
				this.enableMouseListeners();
			}
			
			this._selected = value;
		}
		public function get selected():Boolean	{ return this._selected;	}
		
		// Override some Mouse Event
		/**
		 * click for select button 
		 * @param evt
		 */
		override protected function on_MouseClick(evt:MouseEvent):void
		{
			super.on_MouseClick( evt );
			
			this.selected = true;
		}
		
	}
}