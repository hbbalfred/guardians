package engine.managers
{	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import engine.ui.comps.UIInteractive;
	import engine.utils.FunctionUtils;

	/**
	 * Game Tip Model for Tip display
	 * @author Tang Bo Hao
	 */
	public class TipManager
	{
		// >> ==== Injection ==== <<
		[PBInject] public var viewMgr:ViewManager;
		[PBInject] public var stage:Stage;
		
		// >> ==== Private Functions ==== <<
		protected var _enabledTipsDic:Dictionary = new Dictionary( true );
		protected var _tipInfoDB:Object;
		// current info
		protected var _currTarget:UIInteractive;
		protected var _currTip:Sprite;
		
		// >> ==== Public Functions ==== <<
		/**
		 * Enable UI's tip
		 */		
		public function enableTip( ui:UIInteractive ):void{
			_enabledTipsDic[ui] = FunctionUtils.closurize( onHover_showTip, ui );
			ui.onMouseOver.add( _enabledTipsDic[ui] ); 
		}
		
		/**
		 * Disable UI's tip
		 */
		public function disableTip( ui:UIInteractive ):void{
			var func:Function = _enabledTipsDic[ui];
			if( func != null ){
				if( _currTarget ==  ui)
					onHout_hideTip();
				ui.onMouseOver.remove( func );
				ui.onMouseOut.remove( onHout_hideTip );
				delete _enabledTipsDic[ui];
			}
		}
		
		/**
		 * Init Tip DB from setting
		 * @param data
		 */
		public function initTipDB( data:Object ):void{
			if( !_tipInfoDB )
				_tipInfoDB = data;
		}
		
		// >> ==== Accessors for Current Info ===== <<
		public function get currTarget():UIInteractive { return _currTarget; }
		public function get currTipInfo():Object {	return _tipInfoDB[_currTarget.fullName]; }
		public function get currTip():Sprite	{	return _currTip; }
		public function get tipInfoDB():Object 	{	return _tipInfoDB; }
		
		// >> ==== Tip related Functions ===== <<
		/**
		 * On Tick for moving
		 */
		public function onFrame(...args):void{
			if( _currTip != null ){
				setMousePos( _currTip );
				
				if( !_currTarget.display.hitTestPoint( stage.mouseX, stage.mouseY ) ){
					onHout_hideTip();
				}
			}
		}
		
		/**
		 * Show tip when mouse over
		 * @param ui
		 */
		protected function onHover_showTip( ui:UIInteractive ):void{
			if( !_tipInfoDB ) return;
			
			_currTarget = ui;
			ui.onMouseOut.addOnce( onHout_hideTip ); 
			
			var currentInfo:Object = _tipInfoDB[ ui.fullName ];
			if( currentInfo ){
				// add tip view
				_currTip = viewMgr.addView( currentInfo.type, "tip_", currentInfo);
				setMousePos(_currTip);
				stage.addEventListener(Event.ENTER_FRAME, onFrame);
			}
		}
		
		/**
		 * Hide tip is singleton, since only one mouse
		 */
		protected function onHout_hideTip():void{
			if( !_currTarget ) return;
			
			var currentInfo:Object = _tipInfoDB[ _currTarget.fullName ];
			if( currentInfo ){
				stage.removeEventListener(Event.ENTER_FRAME, onFrame);
				viewMgr.removeView( currentInfo.type, "tip_" );
			}
			
			_currTip = null;
			_currTarget = null;
		}
		
		protected function setMousePos( tipView:Sprite ):void
		{
			var pos:Point = tipView.parent.globalToLocal( new Point( stage.mouseX, stage.mouseY) );
			
			if( pos.x > stage.stageWidth * 3/4 ){
				pos.x -= tipView.width;
			}
			
			if( pos.y > stage.stageHeight - tipView.height * 1.2 ){
				pos.y -= tipView.height;
			}
			
			tipView.x = pos.x;
			tipView.y = pos.y;
		}
	}
}
