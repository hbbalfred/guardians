package engine.ui.comps
{
	import engine.utils.DisplayObjectUtils;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	/**
	 * The base button movieclip wrapper
	 * @author Tang Bo Hao
	 */
	public class UIBaseButton extends UIInteractive
	{
		// button status constants
		public static const STATUS_UP:String = "UP";
		public static const STATUS_OVER:String = "OVER";
		public static const STATUS_DOWN:String = "DOWN";
		public static const STATUS_DISABLE:String = "DISABLE";
		private static const STATUS_ARRAY:Array = [STATUS_UP, STATUS_OVER, STATUS_DOWN, STATUS_DISABLE];

		// private
		protected var _buttonStatus:String; // button status
		
		/**
		 * Init a uibasebutton
		 * @param display
		 */
		public function UIBaseButton(id:String, display:MovieClip, owner:UIComponent)
		{
			super(id, display, owner);
			
			// set stop script to labels
			DisplayObjectUtils.initStopScript(display);
			display.gotoAndStop(1);
			
			// button init
			this._buttonStatus = STATUS_DISABLE;
			
			display.enabled = true;
			
			this.enabled = true;
		}
		
		/**
		 * To dispose the button
		 */
		override public function destroy():void
		{	
			// call super
			super.destroy();
		}

		
		// ==!==== Getter and Setter ========
		/**
		 * set if the button is enabled
		 * @param value
		 */
		override public function set enabled(value:Boolean):void{
			// Set to Gray First
			if(this.grayOnDisable) this.isGray = !value;
			
			if (value){
				if (this.buttonStatus == STATUS_DISABLE){
					this.buttonStatus = STATUS_UP;
				};
			} else {
				this.buttonStatus = STATUS_DISABLE;
			};
		}
		
		/**
		 * set button's status
		 * @param value
		 */
		public function set buttonStatus(value:String):void
		{
			if (this._buttonStatus == value) return;
			
			if (this._buttonStatus == STATUS_DISABLE){
				this.enableMouseListeners();
			}else if (value == STATUS_DISABLE){
				this.disableMouseListeners();
			}
			this._buttonStatus = value;
			// play animation
			this.gotoAndPlay(value);
			// set the buttonEnable
			this._enabled = !(this._buttonStatus == STATUS_DISABLE);
		}
		public function get buttonStatus():String	{ return this._buttonStatus;	}

		// ==!==== Private Functions =======
		/**
		 * wrapper of movieclip's gotoAndPlay
		 * @param label
		 */
		protected function gotoAndPlay(label:Object):void{
			var mc:MovieClip = this.display as MovieClip;
			if (mc.currentLabels.length > 0){ // if have labels
				mc.gotoAndPlay(label);
			} else { // use index
				var index:int = STATUS_ARRAY.indexOf(label);
				mc.gotoAndStop(index + 1);
			}
		}
		
		// ===!==== Mouse Events Handler ======
		/**
		 * Mouse Over 
		 * @param evt
		 */
		override protected function on_MouseOver(evt:MouseEvent):void
		{
			if (!this.overEnable){
				return;
			}
			this.buttonStatus = STATUS_OVER;
			
			super.on_MouseOver(evt);
		}
		/**
		 * Mouse Out
		 * @param evt
		 */
		override protected function on_MouseOut(evt:MouseEvent):void
		{
			this.buttonStatus = STATUS_UP;
			
			super.on_MouseOut(evt);
		}
		
		/**
		 * Mouse Click
		 * @param evt
		 */
		override protected function on_MouseClick(evt:MouseEvent):void
		{
			this.buttonStatus = STATUS_UP;
			
			super.on_MouseClick(evt);
		}
		
		/**
		 * Mouse Down
		 * @param evt
		 */
		override protected function on_MouseDown(evt:MouseEvent):void
		{
			this.buttonStatus = STATUS_DOWN;
			
			super.on_MouseDown(evt);
		}
	}
}
