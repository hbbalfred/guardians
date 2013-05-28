package engine.task
{
	/**
	 * Parallel Command
	 * @author Tang Bo Hao
	 * 
	 */
	public class ParallelTask extends MultiTask
	{
		public function ParallelTask(...commands)
		{
			super("parallel");
			this.addCommands.apply(this, commands);
		}
		/**
		 * Overrides the default execute method to kick off the execution of our commands
		 * Execute the next command available in our array of commands, if there are no
		 * commands left to execute, exits the batch  
		 */
		override protected function execute():void
		{
			super.execute();
			
			for each(var cmd:AbstractTask in workingSubcommands) {
				this.executeSubcommand(cmd);
			}
		}
		
		/**
		 * @inheritDoc 
		 */
		override protected function undo():void
		{
			this.execute();
			
			for each(var cmd:AbstractTask in workingSubcommands) {
				this.undoSubcommand(cmd);
			}
		}
		
		/**
		 * Called in sub command complete 
		 * @param target, the object of completed subcommand
		 */
		override protected function onSubcommandComplete( target:AbstractTask ):void
		{
			super.onSubcommandComplete( target );
			checkComplete();
		}
		
		/**
		 * Called in command failed
		 * @param target, the object of failed subcommand
		 */
		override protected function onSubcommandFailed( target:AbstractTask ):void
		{
			// If there hasn't been a failer to trigger this flag yet, mark the flag
			if(!hasAtLeastOneFailure)
				hasAtLeastOneFailure = true;
			
			super.onSubcommandFailed( target );
			checkComplete();
		}
		
		/**
		 * Goes through all of the commands and checks to see if they all finished 
		 * and if they did so successfuly, if they all finished then we will finish this AsyncCommand. 
		 */	
		private function checkComplete():void
		{
			// Loop through all of the running commands and check if they
			// have been executed and if they failed or not
			for each (var cmd:AbstractTask in workingSubcommands) {
				
				// exit this function if all commands have not yet been executed and completed
				if(cmd.executionStatus != AbstractTask.STA_COMPLETE 
					&& cmd.executionStatus != AbstractTask.STA_FAILED )
					return;
			}
			
			// No matter if we have a failure in the commands, since we started them all together, wait for 
			// them all to finish before saying we are complete or incomplete
			
			if(hasAtLeastOneFailure) {
				// If we have at least one item that failed, and we are not atomic then we failed, dispatch a command incomplete
				// but if we are atomic then who cares, we completed successfully
				isAtomic ? complete() : fail();
			} else {
				// no failures, everything executed successfully, we are complete
				complete(); 
			}
		}		
		
	}
}