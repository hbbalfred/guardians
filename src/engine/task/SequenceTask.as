package engine.task
{
	/**
	 * Sequence Command
	 * @author Tang Bo Hao
	 * 
	 */
	public class SequenceTask extends MultiTask
	{
		private var _order:String = "";
		
		public function SequenceTask(...commands)
		{
			super("sequence");
			this.addCommands.apply(this, commands);
		}
		
		/**
		 * @inheritDoc 
		 */	
		override protected function execute():void
		{
			_order = "!reverse";
			exec();
		}
		
		/**
		 * @inheritDoc 
		 */
		override protected function undo():void
		{
			_order = "reverse";
			exec();
		}
		
		/**
		 * start to execute 
		 */
		private function exec():void
		{
			super.execute();
			this.executeNextCommand();
		}
		
		/**
		 * execution order
		 * in generally undo order is reverse
		 * @return 
		 */
		private function get isReverse():Boolean
		{
			return _order === "reverse";
		}
		
		/**
		 * Execute the next command available in our array of commands, if there are no
		 * commands left to execute, exits the batch 
		 */
		private function executeNextCommand():void
		{
			// Keep executing commands while we have commands in our array
			if(workingSubcommands && workingSubcommands.length > 0) {
				
				// The object holder for all of the info we need to execute each command
				if( isReverse )
				{
					undoSubcommand( workingSubcommands.pop() );
				}
				else
				{
					executeSubcommand( workingSubcommands.shift() );
				}
				
			} else {
				// Ok, we got done with all of our commands in the macro, tell any super macro's we are done
				complete();
			}		
		}
		
		
		/**
		 * Whenever a subcommand completes, its will call this function  
		 * @param target, the object of subcommand
		 */
		override protected function onSubcommandComplete( target:AbstractTask ):void
		{
			super.onSubcommandComplete( target );
			executeNextCommand();
		}
		
		/**
		 * Whenever a subcommand fails, its will call this function  
		 * @param target, the object of subcommand
		 */
		override protected function onSubcommandFailed( target:AbstractTask ):void
		{
			super.onSubcommandFailed( target );
			
			// If we failed, and we are not atomic then we failed, dispatch a command incomplete
			// but if we are atomic then who cares, go to the next command
			isAtomic ? executeNextCommand() : fail();
		}
		
	}
}