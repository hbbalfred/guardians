package engine.bevtree.format
{
	import engine.bevtree.*;

	/**
	 * JSONBevNode
	 * @author hbb
	 */
	public class JSONBevNodePrecondition
	{
		// ----------------------------------------------------------------
		// :: Static
		protected static const AND:String = "and";
		protected static const OR:String = "or";
		protected static const NOT:String = "not";
		protected static const TRUE:String = "true";
		protected static const FALSE:String = "false";
		
		
		/**
		 * parse a json data to behavior node precondition 
		 * @param data, json
		 * @param generator, custom generator to generate a concrete object of BevNodePrecondition
		 * @return 
		 * 
		 */
		public static function parse( data:Object, generator:IBevNodeGenerator  ):BevNodePrecondition
		{
			if( !data )
				throw new ArgumentError("Error: invalid arguments");
			
			if( data is String )
				return generator.precondition( String(data) );
			
			if( !data.condition )
				throw new Error("Error: no define condition.");
			
			var con:BevNodePrecondition;
			switch( data.logic )
			{
				case NOT:	con = createCondition( data.condition, generator, BevNodePreconditionNOT );		break;
				case AND:	con = createCondition( data.condition, generator, BevNodePreconditionAND );		break;
				case OR:	con = createCondition( data.condition, generator, BevNodePreconditionOR );		break;
				case TRUE:	con = createCondition( data.condition, generator, BevNodePreconditionTRUE );	break;
				case FALSE:	con = createCondition( data.condition, generator, BevNodePreconditionFALSE );	break;
				default:	con = generator.precondition( data.condition );
			}
			
			return con;
		}
		
		/**
		 * @protected 
		 * @param data
		 * @param generator
		 * @param clazz
		 * @return 
		 * 
		 */
		protected static function createCondition( data:*, g:IBevNodeGenerator, clazz:Class ):BevNodePrecondition
		{
			var con:BevNodePrecondition;
			
			if( data is String )
			{
				con = new clazz( parse( data, g ) );
			}
			else
			{
				var a:Array = data;
				
				switch( a.length )
				{
					case 0: con = new clazz(); break;
					case 1: con = new clazz( parse(a[0], g) ); break;
					case 2: con = new clazz( parse(a[0], g), parse(a[1], g) ); break;
					case 3: con = new clazz( parse(a[0], g), parse(a[1], g), parse(a[2], g) ); break;
					case 4: con = new clazz( parse(a[0], g), parse(a[1], g), parse(a[2], g), parse(a[3], g) ); break;
					case 5: con = new clazz( parse(a[0], g), parse(a[1], g), parse(a[2], g), parse(a[3], g), parse(a[4], g) ); break;
					default: throw new ArgumentError("Error: invalid arguments length");
				}
			}
			
			return con;
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