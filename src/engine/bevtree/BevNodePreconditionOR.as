package engine.bevtree
{
	/**
	 * BevNodePreconditionOR
	 * @author hbb
	 */
	public class BevNodePreconditionOR extends BevNodePrecondition
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		public function BevNodePreconditionOR( ...rest )
		{
			if( rest.length < 2 )
				throw new ArgumentError("Invalid arguments!");
			
			_list = new Vector.<BevNodePrecondition>( rest.length, true );
			for(var i:int = 0; i < rest.length; ++i)
				_list[i] = rest[i];
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		override public function evaluate(input:BevNodeInputParam):Boolean
		{
			for(var i:int = i, n:int = _list.length; i < n; ++i)
				if( _list[i].evaluate( input ) )
					return true;
			
			return false;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _list:Vector.<BevNodePrecondition>;
		
	}
}