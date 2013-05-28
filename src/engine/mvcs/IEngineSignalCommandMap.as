package engine.mvcs
{
	import org.osflash.signals.ISignal;
	import org.robotlegs.core.ISignalCommandMap;
	
	/**
	 * @inheritDoc
	 * @author Tang Bo Hao
	 */
	public interface IEngineSignalCommandMap extends ISignalCommandMap
	{
		/**
		 * Map behavior signal
		 * @param signal
		 * @param commandClass
		 * @param behaviorName
		 * @param oneshot
		 * 
		 */
		function mapBehaviorSignal(signal:ISignal, commandClass:Class, behaviorName:String, oneshot:Boolean = false):void;
		
		/**
		 * Map behavior signal, with fallback
		 * @param signal
		 * @param commandClass
		 * @param fallbackCommandClass
		 * @param behaviorName
		 * @param oneshot
		 * 
		 */
		function mapBehaviorSignalWithFallback(signal:ISignal, commandClass:Class, fallbackCommandClass:Class, behaviorName:String, oneshot:Boolean = false):void;
	}
}