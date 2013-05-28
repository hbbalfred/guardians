package engine
{
	import engine.framework.core.PBGroup;

	/**
	 * Root PBGroup of the game
	 * @author Tang Bo Hao
	 * 
	 */
	public class EngineContext extends PBGroup
	{
		override public function initialize():void
		{
			super.initialize();
			super.name = "EngineContext_Group";
		}
	}
}