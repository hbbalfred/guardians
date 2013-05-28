package engine.framework
{
    import engine.framework.core.PBGroup;

    /**
     * Helper class to track a few important bits of global state.
     */
    public class PBE
    {        
        /**
         * To facilitate debugging, any PBGroup that you don't put in a group
         * is added here. The console lets you inspect this group with the tree
         * command. So, you can easily see the total object graph of your game
         * for debugging purposes. 
         */
        pb_internal static var _rootGroup:PBGroup = new PBGroup("_RootGroup");
    }
}