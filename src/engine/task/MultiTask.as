package engine.task
{
	import org.osflash.signals.Signal;

	/**
	 * Base class for Parallel and Serial Command
	 * @author Tang Bo Hao
	 * 
	 */
	public class MultiTask extends AbstractTask
	{
		public const sig_subComplete:Signal = new Signal;
		public const sig_subStart:Signal = new Signal;
		
		/**
		 * Keeps track each execution cycle if at least one command has failed
		 */		
		internal var hasAtLeastOneFailure:Boolean;
		
		/**
		 * This is a copy of subcommand_internal but one that we can edit and remove
		 * finished items from
		 */		
		internal var workingSubcommands:Vector.<AbstractTask>;

		/**
		* The an array of command descriptors that contains what commands we will be executing
		* But this will only ever be added too, and will not be removed from
		*/		
		private var _subcommands:Vector.<AbstractTask>;
		
		/**
		 * Don't ever allow the user to get a hold of the original subcommand array to edit it in anyway
		 * @return A new array of subcommand descriptors
		 */		
		public function get subcommands():Vector.<AbstractTask> {
			return _subcommands.concat();
		}
		
		/**
		 * Determines if the commands are interdependant.  For example: if one command in a sequence fails
		 * then the whole batch fails and exits immediately.  If one command in the parallel fails, all will 
		 * finish executing, but the batch command itself will fail
		 * 
		 * isAtomic = true : This means they are NOT dependant on each other
		 * isAtomic = false : This means that they ARE dependant on each other
		 */		
		public var isAtomic:Boolean = true;
		
		/**
		 * @inheritDoc 
		 */
		override public function clear():void
		{
			super.clear();
			
			sig_subStart.removeAll();
			sig_subComplete.removeAll();
			
			if(_subcommands){
				for(var i:int = _subcommands.length - 1; i > -1; --i)
					_subcommands[i].clear();
				
				_subcommands.length = 0;
			}
			
			if(workingSubcommands) workingSubcommands.length = 0;
		}
		
		/**
		 * Constructor 
		 * @param type
		 */
		public function MultiTask( type:String = "multi" )
		{
			super(type);
			
			hasAtLeastOneFailure = false;
			_subcommands = new Vector.<AbstractTask>;
		}
		
		/**
		 * Overrides the default execute method to kick off the execution of our commands 
		 */		
		override protected function execute():void
		{
			workingSubcommands = _subcommands.concat();
		}
		
		/**
		 * add a command to the queue to be executed
		 * @param cmd
		 * @return the command self for link-style programming
		 */		
		public function addCommand(cmd:AbstractTask):MultiTask
		{
			_subcommands.push(cmd);
			return this;
		}
		
		/**
		 * add a bunch of command at once 
		 * @param ...commands
		 * @return the command self for link-style programming
		 * 
		 */
		public function addCommands(...commands):MultiTask
		{
			for each( var cmd:AbstractTask in commands)
			{
				this.addCommand(cmd);
			}
			return this;
		}
		
		/**
		 * Executes the subcommand that is passed in 
		 * @param cmd The AsyncCommand to execute
		 */		
		internal function executeSubcommand(cmd:AbstractTask):void
		{
			cmd.sig_complete.addOnce( onSubcommandComplete );
			cmd.sig_fail.addOnce( onSubcommandFailed );
			cmd.start();
			
			sig_subStart.dispatch( this, cmd );
		}
		
		/**
		 * undo the subcommand that is passed in 
		 * @param cmd The AsyncCommand to execute
		 */		
		internal function undoSubcommand(cmd:AbstractTask):void
		{
			cmd.sig_complete.addOnce( onSubcommandComplete );
			cmd.sig_fail.addOnce( onSubcommandFailed );
			cmd.startUndo();
			
			sig_subStart.dispatch( this, cmd );
		}
		
		/**
		 * Called whenever a subcommand completes successfully 
		 * Can be overridden by any class implemented MultiCommand to listen
		 * for when each subcommand is finished
		 * @param target the object containing the command that was executed
		 */		
		protected function onSubcommandComplete(target:AbstractTask):void
		{
			target.sig_complete.remove(onSubcommandComplete);
			target.sig_fail.remove(onSubcommandFailed);
			
			sig_subComplete.dispatch( this, target );
		}
		
		/**
		 * Called whenever a subcommand completes unsuccessfully 
		 * Can be overridden by any class implemented MultiCommand to listen
		 * for when each subcommand is failed
		 * @param target, the object containing the command that was executed
		 */	
		protected function onSubcommandFailed(target:AbstractTask):void
		{
			target.sig_complete.remove(onSubcommandComplete);
			target.sig_fail.remove(onSubcommandFailed);
		} 
	}
}