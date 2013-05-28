package engine.mvcs
{
	import engine.EngineContext;
	
	import org.robotlegs.base.SignalCommandMap;
	import org.robotlegs.core.IInjector;
	
	/**
	 * a Guarded Signal Command Map with Engine Context Injected
	 * @author Tang Bo Hao
	 * 
	 */
	public class EngineSignalCommandMap extends SignalCommandMap// implements IEngineSignalCommandMap
	{
		private var _engineCxt:EngineContext;
		
		public function EngineSignalCommandMap(injector:IInjector, engine:EngineContext)
		{
			super(injector);
			
			this._engineCxt = engine;
		}
		
		/**
		 * create the Command Instance and inject engine mapping to it
		 * @inheritDoc
		 */
		override protected function createCommandInstance(commandClass:Class):Object
		{
			var retObj:Object = super.createCommandInstance(commandClass);
			this._engineCxt.injectInto(retObj);
			return retObj;
		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function mapBehaviorSignal(signal:ISignal, commandClass:Class, behaviorName:String, oneshot:Boolean=false):void
//		{
//			mapBehaviorSignalWithFallback(signal, commandClass, null, behaviorName, oneshot);
//		}
//		
//		/**
//		 * @inheritDoc
//		 */
//		public function mapBehaviorSignalWithFallback(signal:ISignal, commandClass:Class, fallbackCommandClass:Class, behaviorName:String, oneshot:Boolean=false):void
//		{
//			verifyCommandClass(commandClass);
//			
//			if (hasSignalCommand(signal, commandClass))
//				return;
//			
//			const signalCommandMap:Dictionary = signalMap[signal] = signalMap[signal] || new Dictionary(false);
//			
//			const callback:Function = function():void 
//			{
//				routeSignalToBehaviorCommand(signal, arguments, commandClass, fallbackCommandClass, oneshot, behaviorName);
//			};
//			
//			signalCommandMap[commandClass] = callback;
//			signal.add(callback);
//		}
//		
//		
//		protected function routeSignalToBehaviorCommand(signal:ISignal, valueObjects:Array, commandClass:Class, fallbackCommandClass:Class, oneshot:Boolean, behaviorId:String):void
//		{	
//			mapSignalValues(signal.valueClasses, valueObjects);
//			
//			var behaviorCenter:BehaviorCenter = _engineCxt.getManager(BehaviorCenter) as BehaviorCenter;
//			var approved:Boolean = behaviorCenter.doBehavior(behaviorId);
//			
//			if ((!approved) && (fallbackCommandClass == null)) {
//				unmapSignalValues(signal.valueClasses, valueObjects);
//				return;
//			}
//			
//			var commandToInstantiate:Class = approved ? commandClass : fallbackCommandClass;
//			
//			var command:Object = createCommandInstance(commandToInstantiate);
//			unmapSignalValues(signal.valueClasses, valueObjects);
//			command.execute();
//			
//			if (oneshot)
//				unmapSignal(signal, commandClass);
//			
//		}
	}
}