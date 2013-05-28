package engine.utils 
{
	/**
	 * Function Utilities Class
	 * @author Tang Bo Hao
	 * 
	 */
	public class FunctionUtils 
	{	
		/**
		 * Return a function that calls a specified function with the provided arguments.
		 * 
		 * For instance, function a(b,c) through closurize(a, b, c) becomes 
		 * a function() that calls function a(b,c);
		 * 
		 * Thanks to Rob Sampson <www.calypso88.com>.
		 */
		public static function closurize(func:Function, ...args):Function
		{
			// Create a new function...
			return function(...nouse):* 
			{
				// Call the original function with provided args.
				return func.apply(this, args);
			}
		}
		
		/**
		 * Return a function that calls a specified function with the provided arguments
		 * APPENDED to its provided arguments.
		 * 
		 * For instance, function a(b,c) through closurizeAppend(a, c) becomes 
		 * a function(b) that calls function a(b,c);
		 */
		public static function closurizeAppend(func:Function, ...additionalArgs):Function
		{
			// Create a new function...
			return function(...localArgs):* 
			{
				// Combine parameter lists.
				var argsCopy:Array = localArgs.concat(additionalArgs);
				
				// Call the original function.
				return func.apply(this, argsCopy);
			}
		}

	}
} 
