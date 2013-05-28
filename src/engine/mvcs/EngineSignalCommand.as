package engine.mvcs
{
	import org.robotlegs.mvcs.Command;
	
	/**
	 * Engine Signal Command Base class with guarded command map
	 * @author Tang Bo Hao
	 */
	public class EngineSignalCommand extends Command
	{
		[Inject]
		public var signalCommandMap:EngineSignalCommandMap;
	}
}