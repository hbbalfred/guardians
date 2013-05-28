package engine.ui.comps
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import engine.managers.BehaviorManager;
	import engine.managers.SoundManager;
	import engine.managers.TipManager;
	import engine.ui.decorators.GlowDecorator;
	import engine.utils.DisplayObjectUtils;
	import engine.utils.InteractivePNG;
	
	import org.osflash.signals.Signal;

	/**
	 * The base button movieclip wrapper
	 * @author Tang Bo Hao
	 */
	public class UIInteractive extends UIComponent
	{
		// interactivePNG name constant
		protected static const REG_InteractivePNG:RegExp = /^\$interactivePNG\$/;
		
		// >> ====== button status constants ======= <<
		public static const STATUS_ENABLE:String = "ENABLE";
		public static const STATUS_DISABLE:String = "DISABLE";
		private static const STATUS_ARRAY:Array = [STATUS_ENABLE, STATUS_DISABLE];
		public static const DEFAULT_GLOWSTRENGTH:Number = 2.5;
		
		// Common Static Setting
		public static var COMMON_CLICK_SFX:String = null;
		
		// Public Member for mouse release 
		public var releaseWhenOut:Boolean = false;
		
		// >> ====== Injection ======= <<
		[PBInject] public var tipMgr:TipManager;
		[PBInject] public var soundMgr:SoundManager;
		[PBInject] public var bevMgr:BehaviorManager;
		
		// >> ====== Private ======= <<
		protected var _enabled:Boolean; // if this enabled
		protected var _pressingEnabled:Boolean; // if the interactive object accpet pressing event
		protected var _overEnabled:Boolean; // if interactive object accept over event
		protected var _tipEnable:Boolean; // tip display is in tipManager
		
		// Interactive Effect
		protected var _glowEffectEnabled:Boolean;// if interactive object has glow effect
		protected var _glowEffect:GlowDecorator;
		protected var _glowShowing:Boolean;
		protected var _glowEffectStrengh:Number;
		private var _grayOnDisable:Boolean = false;
		
		// Signals
		protected var _onMouseClick:Signal;
		protected var _onMouseDown:Signal;
		protected var _onMousePressing:Signal;	
		protected var _onMouseReleased:Signal;
		protected var _onMouseOut:Signal;
		protected var _onMouseOver:Signal;
		
		/**
		 * Init a uibasebutton
		 * @param display
		 */
		public function UIInteractive(id:String, display:Sprite, owner:UIComponent)
		{
			// To Check if the display is InteractivePNG
			if(display.name.match(REG_InteractivePNG)){
				var interPNG:InteractivePNG = new InteractivePNG;
				DisplayObjectUtils.wrapDisplayObject(display, interPNG);
				display = interPNG;
			}
			
			// Call Super
			super(id, display, owner);
			
			// interactive init
			this._overEnabled = true;
			this._pressingEnabled = false;
			this._tipEnable = false;
			
			// set mouseChildren
			display.mouseChildren = false;
			if( owner is UIInteractive ){
				UIInteractive(owner).display.mouseChildren = true;
			}
		}
		
		/**
		 * To dispose the button
		 */
		override public function destroy():void
		{
			this.disableMouseListeners();
			
			if(this._glowEffect){
				this._glowEffect.strength = 0;
				this._glowEffect = null;
			}
			
			// remove tip if enabled
			if( _tipEnable && tipMgr){
				tipMgr.disableTip( this );
			}
			
			// clear signals
			clearSignal(_onMouseClick);
			clearSignal(_onMouseDown);
			clearSignal(_onMouseOut);
			clearSignal(_onMouseOver);
			clearSignal(_onMousePressing);			
			clearSignal(_onMouseReleased);
			
			// call super
			super.destroy();
		}
		// ==!==== Getter and Setter ========
		/**
		 * get button display
		 * @return 
		 */
		public function get display():Sprite
		{
			return this._display as Sprite;
		}
		
		/**
		 * This function is used for fast-adding listener to the button 
		 * and enable button
		 * @param func 
		 * @param once default is true
		 */
		public function enableClick( func:Function, once:Boolean = true):Boolean
		{
			if( func == null) return false;
			
			this.enabled = true;
			if(once)
				this.onMouseClick.addOnce(func);
			else
				this.onMouseClick.add(func);
			
			return true;
		}
		
		/**
		 * This function is used for fast removing listeners from the button
		 * and disable button
		 */
		override public function disableClick():void
		{
			this.onMouseClick.removeAll();
			this.enabled = false;
		}
		
		/**
		 * Easy way to reset click
		 * @param func
		 * @param once
		 * @return 
		 */
		public function resetClick( func:Function, once:Boolean = true):Boolean
		{
			this.onMouseClick.removeAll();
			return this.enableClick( func, once );
		}
		
		/**
		 * Interactive Item tips
		 * @param value
		 * @param noHand
		 */
		public function tipState(value:Boolean, noHand:Boolean = true ):void{
			if( this._tipEnable == value || !tipMgr) return;
			
			if( value ){ // set to enable
				enabled = true;
				overEnable = true;
				if( noHand ){
					this.display.buttonMode = false;
					this.display.useHandCursor = false;
				}
				tipMgr.enableTip( this );
			}else{ // set to disable
				tipMgr.disableTip( this );
			}
			
			_tipEnable = value;
		}
		
		/**
		 * Set if handle pressing event
		 * @param value
		 */
		public function set pressingEnabled(value:Boolean):void	{	this._pressingEnabled = value;	}
		public function get pressingEnabled():Boolean	{ return this._pressingEnabled;		}
		
		/**
		 * Set if handle rollover rollout event
		 * @param value
		 */
		public function set overEnable(value:Boolean):void
		{
			if(!_enabled || this._overEnabled == value) return;
			
			if (value){ // if set to enable
				this.display.addEventListener(MouseEvent.ROLL_OUT, this.on_MouseOut);
				this.display.addEventListener(MouseEvent.ROLL_OVER, this.on_MouseOver);
			}else{ // if set to disable
				this.display.removeEventListener(MouseEvent.ROLL_OUT, this.on_MouseOut);
				this.display.removeEventListener(MouseEvent.ROLL_OVER, this.on_MouseOver);
			};
			this._overEnabled = value;
		}
		public function get overEnable():Boolean	{ return this._overEnabled; }
		
		/**
		 * set if the button is enabled
		 * @param value
		 */
		public function set enabled(value:Boolean):void{
			// Set to Gray First
			if(this._grayOnDisable) this.isGray = !value;
			// if same then return
			if(value == this._enabled) return;
			
			if (value){
				this.enableMouseListeners();
			} else {
				this.disableMouseListeners();
			}
			this._enabled =  value;
		}
		public function get enabled():Boolean { return this._enabled;	}
		
		public function set grayOnDisable(b:Boolean):void{
			this._grayOnDisable = b;
		}
		
		public function get grayOnDisable():Boolean {
			return this._grayOnDisable;
		}
		
		/**
		 * @inhertDoc
		 */
		override public function set activated(value:Boolean):void{
			var lastValue:Boolean = this._activate;
			super.activated = value;
			
			if( this._glowEffectEnabled ){
				if(!lastValue && value){
					glowEffectStrength = glowEffectStrength * 2;
				}else if(lastValue && !value){
					glowEffectStrength = glowEffectStrength / 2;
				}
				glowShowing = value;
			}
		}
		
		/**
		 * Enable Glow Effect
		 */
		public function set glowEffectEnabled(value:Boolean):void
		{
			if(value == this._glowEffectEnabled) return;// if same then return
			
			if(value){
				this.glowEffect.strength = 0;
			}
			this._glowEffectEnabled = value;
		}
		public function get glowEffectEnabled():Boolean {  return this._glowEffectEnabled; }
		
		/**
		 * get glow Effect decorator 
		 * @param value
		 */
		public function get glowEffect():GlowDecorator { return this._glowEffect ||= new GlowDecorator(display); }
		
		/**
		 * The Glow Effect Strength
		 */
		public function set glowEffectStrength( value:Number ):void{
			if(!this._glowEffectEnabled || this._glowEffectStrengh == value) return;
			_glowEffectStrengh = value;
		}
		public function get glowEffectStrength():Number {	return _glowEffectStrengh ||= DEFAULT_GLOWSTRENGTH; }
		
		/**
		 * To Show Glow Effect
		 */
		public function set glowShowing( value:Boolean ):void{
			if(!this._glowEffectEnabled) return;
			
			if(value){
				if(this._glowEffect.delay > 0){
					tweenMgr.remove(this._glowEffect);
					tweenMgr.add(this._glowEffect, { strength: glowEffectStrength }, {time: this.glowEffect.delay});
				}else{
					this._glowEffect.strength = glowEffectStrength;
				}
			}else{
				if(this.glowEffect.delay > 0){
					tweenMgr.remove(this._glowEffect);
					tweenMgr.add(this._glowEffect, { strength: 0 }, {time: this.glowEffect.delay });
				}else{
					this._glowEffect.strength = 0;
				}
			}
			_glowShowing = value;
		}
		public function get glowShowing():Boolean	{	return this._glowShowing;	}
		
		// ===!==== Signals Getters ======
		/**
		 * All mouse signal's parameter is StageX and StageY
		 * @return
		 */
		public function get onMouseReleased():Signal{
			return _onMouseReleased ||= bevMgr.create( this.fullName );
		}
		
		public function get onMousePressing():Signal{
			return _onMousePressing ||= bevMgr.create( this.fullName );
		}
		
		public function get onMouseDown():Signal{
			return _onMouseDown ||= bevMgr.create( this.fullName );
		}
		
		public function get onMouseClick():Signal{
			return _onMouseClick ||= bevMgr.create( this.fullName );
		}
		
		public function get onMouseOver():Signal{
			return _onMouseOver ||= new Signal;
		}
		
		public function get onMouseOut():Signal{
			return _onMouseOut ||= new Signal;
		}
		
		/**
		 * Enable all mouse listeners
		 */
		protected function enableMouseListeners():void
		{
			if(!(display is InteractivePNG)){
				this.display.mouseEnabled = true;
			}
			
			this.display.addEventListener(MouseEvent.CLICK, this.on_MouseClick);
			this.display.addEventListener(MouseEvent.MOUSE_DOWN, this.on_MouseDown);
			
			if (this._overEnabled){ //if over enabled, bind it
				this.display.addEventListener(MouseEvent.ROLL_OUT, this.on_MouseOut);
				this.display.addEventListener(MouseEvent.ROLL_OVER, this.on_MouseOver);
			}
			//as a button
			this.display.buttonMode = true;
			this.display.useHandCursor = true;
		}
		
		/**
		 * Disable all mouse listeners
		 */
		protected function disableMouseListeners():void
		{
			this.display.removeEventListener(MouseEvent.CLICK, this.on_MouseClick);
			this.display.removeEventListener(MouseEvent.MOUSE_DOWN, this.on_MouseDown);
			
			if (this._overEnabled){ // if over enabled, unbind it
				this.display.removeEventListener(MouseEvent.ROLL_OUT, this.on_MouseOut);
				this.display.removeEventListener(MouseEvent.ROLL_OVER, this.on_MouseOver);
				// dispatch out hack
				this.onMouseOut.dispatch();
			}
			
			if (this._pressingEnabled){
				this.on_pressingRelease(null);
			}
			// not a button
			this.display.buttonMode = false;
			this.display.useHandCursor = false;
			
			if(!(display is InteractivePNG)){
				this.display.mouseEnabled = false;
			}
		}
		
		// ===!==== Mouse Events Handler ======
		/**
		 * Mouse Over 
		 * @param evt
		 */
		protected function on_MouseOver(evt:MouseEvent):void
		{
			if (!this.overEnable){
				return;
			}
			
			if(this._glowEffectEnabled && !this._activate ) this.glowShowing = true;
			
			if(_onMouseOver) _onMouseOver.dispatch();
		}
		/**
		 * Mouse Out
		 * @param evt
		 */
		protected function on_MouseOut(evt:MouseEvent):void
		{
			// add mouse out effect
			if(this._glowEffectEnabled && !this._activate ) this.glowShowing = false;
			
			if (this.pressingEnabled && releaseWhenOut){// if pressing enabled, try remove pressing staff 
				this.on_pressingRelease(null);
			}
			
			if(_onMouseOut) _onMouseOut.dispatch();
		}
		
		/**
		 * Mouse Click
		 * @param evt
		 */
		protected function on_MouseClick(evt:MouseEvent):void
		{
			if(_onMouseClick){
				if( soundMgr && COMMON_CLICK_SFX 
				 && _onMouseClick.numListeners > 0 ){
					soundMgr.beep( COMMON_CLICK_SFX );
				}
				
				this._onMouseClick.dispatch();
			}
			
			evt.stopPropagation();
		}
		
		/**
		 * Mouse Down
		 * @param evt
		 */
		protected function on_MouseDown(evt:MouseEvent):void
		{
			if(this.pressingEnabled){
				this.display.addEventListener(Event.ENTER_FRAME, this.on_MousePressing);
				this.display.stage.addEventListener(MouseEvent.MOUSE_UP, this.on_pressingRelease);
			}
			
			if(_onMouseDown) _onMouseDown.dispatch(evt.stageX, evt.stageY);
			
			evt.stopPropagation();
		}
		
		/**
		 * Enterframe when mouse pressing
		 * @param evt
		 */
		protected function on_MousePressing(evt:Event):void{
			var stage:Stage = this.display.stage;
			if(stage && _onMousePressing)	_onMousePressing.dispatch(stage.mouseX, stage.mouseY);
		}
		protected function on_pressingRelease( evt:MouseEvent = null):void
		{
			this.display.removeEventListener(Event.ENTER_FRAME, this.on_MousePressing);
			this.display.stage.removeEventListener(MouseEvent.MOUSE_UP, this.on_pressingRelease);
			
			if(evt){
				if(_onMouseReleased) _onMouseReleased.dispatch(evt.stageX, evt.stageY);
				evt.stopPropagation();
			}else{
				var stage:Stage = this.display.stage;
				if(stage && _onMouseReleased)	_onMouseReleased.dispatch(stage.mouseX, stage.mouseY);
			}
		}
		
	}
}
