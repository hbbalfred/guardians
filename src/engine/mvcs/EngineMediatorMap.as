package engine.mvcs
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import engine.EngineContext;
	
	import org.robotlegs.base.MediatorMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IReflector;
	
	/**
	 * the Mediator Map with Engine Context injected
	 * @author Tang Bo Hao
	 * 
	 */
	public class EngineMediatorMap extends MediatorMap
	{
		// the engine
		private var _engineCxt:EngineContext;
		private var _initialzationDataMap:Dictionary;
		
		public function EngineMediatorMap(contextView:DisplayObjectContainer, injector:IInjector, reflector:IReflector, engineCxt:EngineContext)
		{
			super(contextView, injector, reflector);
			this._engineCxt = engineCxt;
			_initialzationDataMap = new Dictionary;
		}
		
		/**
		 * Create and inject engine context
		 * @param mediatorClass
		 * @return 
		 */
		override protected function createMediatorInstance(mediatorClass:Class):IMediator
		{
			var mediator:IMediator = super.createMediatorInstance(mediatorClass);
			this._engineCxt.injectInto(mediator);
			return mediator;
		}
		
		/**
		 * @private
		 */		
		override protected function addListeners():void
		{
			if (contextView && enabled)
			{
				contextView.addEventListener(EngineMediatorEvent.VIEW_ADDED, onViewAdded, useCapture, 0, true);
				contextView.addEventListener(EngineMediatorEvent.VIEW_REMOVED, onViewRemoved, useCapture, 0, true);
				contextView.addEventListener(EngineMediatorEvent.VIEW_ACTIVATED, onViewActivated, useCapture, 0, true);
				contextView.addEventListener(EngineMediatorEvent.VIEW_DEACTIVATED, onViewDeactivated, useCapture, 0, true);
			}
		}
		
		/**
		 * @private
		 */		
		override protected function removeListeners():void
		{
			if (contextView)
			{
				contextView.removeEventListener(EngineMediatorEvent.VIEW_ADDED, onViewAdded, useCapture);
				contextView.removeEventListener(EngineMediatorEvent.VIEW_REMOVED, onViewRemoved, useCapture);
				contextView.removeEventListener(EngineMediatorEvent.VIEW_ACTIVATED, onViewActivated, useCapture);
				contextView.removeEventListener(EngineMediatorEvent.VIEW_DEACTIVATED, onViewDeactivated, useCapture);
			}
		}
		
		override protected function onViewAdded(e:Event):void
		{
			var evt:EngineMediatorEvent = e as EngineMediatorEvent;
			
			_initialzationDataMap[e.target] = evt.data;
			super.onViewAdded(e);
		}
		
		/**
		 * Before Register Init the mediator first
		 */
		override public function registerMediator(viewComponent:Object, mediator:IMediator):void
		{
			if( _initialzationDataMap[viewComponent] ){
				if( mediator as IEngineMediator )
					IEngineMediator(mediator).onInitialize( _initialzationDataMap[viewComponent] );
				delete _initialzationDataMap[viewComponent];
			}
			// register it now
			super.registerMediator(viewComponent, mediator);
		}
		
		/**
		 * called when the view really activated
		 */
		protected function onViewActivated(e:Event):void
		{
			var mediator:IEngineMediator = this.retrieveMediator(e.target) as IEngineMediator;
			if(mediator){
				mediator.onActivate();
			}
		}
		/**
		 * called when the view actually deactivated
		 */
		protected function onViewDeactivated(e:Event):void
		{
			var mediator:IEngineMediator = this.retrieveMediator(e.target) as IEngineMediator;
			if(mediator){
				mediator.onDeactivate();
			}
		}
	}
}