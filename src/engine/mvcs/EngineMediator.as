package engine.mvcs
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	
	import engine.framework.util.TypeUtility;
	import engine.managers.BehaviorManager;
	import engine.ui.UICompFactory;
	import engine.ui.comps.UIComponent;
	
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.SignalMediator;
	
	public class EngineMediator extends SignalMediator implements IEngineMediator
	{
		// >> Injection <<
		[PBInject] public var uifactory:UICompFactory;
		[PBInject] public var bevMgr:BehaviorManager;
		
		[Inject] public var cmdMap:EngineSignalCommandMap;
		
		public var ui:UIComponent;
		
		protected var sig_activate:Signal;
		protected var sig_deactivate:Signal;
		
		public function onInitialize(data:*):void
		{
			// nothing to be overrided
		}
		
		/**
		 * invoked when the view really activated
		 */
		public function onActivate():void
		{
			sig_activate.dispatch();
		}
		
		/**
		 * invoked when the view actually deactivated
		 */
		public function onDeactivate():void
		{			
			sig_deactivate.dispatch();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function onRegister():void
		{
			display.name = "$"+uitype+"$"+ TypeUtility.getObjectClassName(display) +"$$";
			ui = uifactory.createUI(this.viewComponent as InteractiveObject);
			
			sig_activate = bevMgr.create( ui.fullName + ".activate" );
			sig_deactivate = bevMgr.create( ui.fullName + ".deactivate" );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function onRemove():void
		{
			if(ui){
				ui.destroy();
				ui = null;
			}
		}
		
		/**
		 * a getter for convienient
		 * @return 
		 */
		protected function get display():DisplayObjectContainer
		{
			return DisplayObjectContainer(this.viewComponent);
		}
		
		/**
		 * default ui type  
		 */
		protected function get uitype():String{ return "base"; }
	}
}