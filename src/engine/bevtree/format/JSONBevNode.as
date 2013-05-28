package engine.bevtree.format
{
	import engine.bevtree.*;

	/**
	 * JSONBevNode
	 * @author hbb
	 */
	public class JSONBevNode
	{
		// ----------------------------------------------------------------
		// :: Static
		
		protected static const LOOP:String = "lp";
		protected static const NONEPRIORITYSELECTOR:String = "nps";
		protected static const PRIORITYSELECTOR:String = "ps";
		protected static const SEQUENCE:String = "sq";
		protected static const SEQUENCESYNC:String = "sqs";
		protected static const PARALLEL:String = "pl";
		
		/**
		 * parse a json data to behavior node 
		 * @param data, json
		 * @param generator, custom generator to generate a concrete object of BevNode
		 * @return 
		 * 
		 */
		public static function parse( data:Object, generator:IBevNodeGenerator  ):BevNode
		{
			if( !data )
				throw new ArgumentError("Error: invalid arguments.");
			
			// create directly from the expression
			if( data is String )
				return generator.behavior( String(data) );
			
			if( !data.behavior )
				throw new Error("Error: no define behavior.");
			
			// create bevnode object
			var node:BevNode;
			switch( data.bevlogic )
			{
				case PRIORITYSELECTOR:
					node = new BevNodePrioritySelector( data.debugname );
					break;
				case SEQUENCE:
					node = new BevNodeSequence( data.debugname );
					break;
				case SEQUENCESYNC:
					node = new BevNodeSequenceSync( data.debugname );
					break;
				case NONEPRIORITYSELECTOR:
					node = new BevNodeNonePrioritySelector( data.debugname );
					break;
				case PARALLEL:
					node = new BevNodeParallel( data.debugname );
					if( data.finishCondition == "and" )
						BevNodeParallel(node).setFinishCondition( BevNodeParallel.CON_AND );
					break;
				case LOOP:
					node = new BevNodeLoop( data.debugname );
					if( data.loopCount )
						BevNodeLoop(node).setLoopCount( Number(data.loopCount) );
					break;
				default:
					node = generator.behavior( data.behavior );
			}
			
			// check and create the precondition
			if( data.condition )
			{
				var con:BevNodePrecondition = JSONBevNodePrecondition.parse( data.condition, generator );
				node.setPrecondition( con );
			}
			
			// check and create the child bevnode
			if( data.behavior is Array )
			{
				var a:Array = data.behavior;
				for(var i:int = 0; i < a.length; ++i)
				{
					node.addChild( parse( a[i], generator ) );
				}
			}
			
			return node;
		}
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}