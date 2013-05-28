package engine.particle.initializers
{
	import avmplus.getQualifiedClassName;
	
	import engine.particle.core.Initializer;
	import engine.particle.core.Particle;
	
	import flash.geom.Point;
	
	/**
	 * PropInit
	 * @author hbb
	 */
	public class PropInit implements Initializer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * initialize a particle by data
		 * if data is a collection then iterate to init
		 */
		public function PropInit( data:* )
		{
			_data = data;
			_index = 0;
		}
		
		public function init(p:Particle):void
		{
			if( !_data )
				return;
			
			
			if(_data is Array
			|| getQualifiedClassName(_data).indexOf('__AS3__.vec::Vector') == 0 )
			{
				copy( _data[_index], p );
				if( ++_index == _data.length )
					_index = 0;
			}
			else
			{
				copy( _data, p );
			}
			
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		private function copy( source:*, p:Particle ):void
		{
			if( source is Point )
			{
				p.x = source.x;
				p.y = source.y;
			}
			else
			{
				for(var i:String in source)
					if( i in p )
						p[i] = source[i];
			}
		}
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _data:*;
		
		private var _index:int;
	}
}