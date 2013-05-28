package engine.mvcs
{
	import org.robotlegs.core.IMediator;
	
	/**
	 * interface for EngineMediator
	 * @author Tang Bo Hao
	 */
	public interface IEngineMediator extends IMediator
	{
		function onInitialize(data:*):void;
		function onActivate():void;
		function onDeactivate():void;
	}
}