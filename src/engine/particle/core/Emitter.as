package engine.particle.core
{
	import org.osflash.signals.Signal;

	/**
	 * Emitter
	 * @author hbb
	 */
	public class Emitter
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		public const sig_add:Signal = new Signal( Particle );
		public const sig_remove:Signal = new Signal( Particle );
		
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		public var rotation:Number = 0.0;

		/**
		 * emitter actived 
		 */
		public function get isActived():Boolean
		{
			if( _particles.length > 0 )
				return true;
			
			for( var i:int = _creators.length - 1; i > -1; --i)
				if( _creators[i].isActived )
					return true;
			
			return false;
		}
		
		public function get creators():Vector.<Creator>{ return _creators; }
		public function get intializers():Vector.<Initializer>{ return _initializers; }
		public function get actions():Vector.<Action>{ return _actions; }
		public function get particles():Vector.<Particle>{ return _particles; }
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function Emitter()
		{
			_creators = new Vector.<Creator>;
			_initializers = new Vector.<Initializer>;
			_actions = new Vector.<Action>;
			_particles = new Vector.<Particle>;
		}
		
		public function destroy():void
		{
			sig_add.removeAll();
			sig_remove.removeAll();
			
			for(var i:int = _particles.length - 1; i > -1; --i)
				removeParticle( i );
		}
		
		public function addCreator( ob:Creator ):Emitter
		{
			_creators.push( ob );
			return this;
		}
		
		public function addInitializer( ob:Initializer ):Emitter
		{
			_initializers.push( ob );
			return this;
		}
		
		public function addAction( ob:Action ):Emitter
		{
			_actions.push( ob );
			return this;
		}
		
		public function update( delta:Number ):void
		{
			var i:int, j:int;
			var p:Particle;
			// check to create
			var plen:int, alen:int;
			var ps:Vector.<Particle>;
			var clen:int = _creators.length;
			for( i = 0; i < clen; ++i)
			{
				if( _creators[i].check( delta ) )
				{
					ps = _creators[i].create();
					plen = ps.length;
					for( j = 0; j < plen; ++j )
					{
						addParticle( ps[j] );
					}
				}
			}
			
			// update
			plen = _particles.length;
			alen = _actions.length;
			for( i = 0; i < plen; ++i )
			{
				p = _particles[i];
				for( j = 0; j < alen; ++j )
					_actions[j].execute( p, delta, this );
			}
			
			// remove
			plen = _particles.length;
			for( i = plen - 1; i > -1; --i)
			{
				p = _particles[i];
				if( p.isDead )
					removeParticle( i );
			}
		}
		
		public function localParticle( p:Particle ):void
		{
			if( rotation == 0 )
			{
				p.x += x;
				p.y += y;
			}
			else
			{
				var cos:Number = Math.cos( rotation );
				var sin:Number = Math.sin( rotation );
				var px:Number = p.x;
				var py:Number = p.y;
				p.x = x + cos * px - sin * py;
				p.y = y + cos * py + sin * px;
			}
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		private function addParticle( p:Particle ):void
		{
			var n:int = _initializers.length;
			for(var i:int = 0; i < n; ++i)
				_initializers[i].init( p );
			
			localParticle( p );
			
			_particles.push( p );
			
			sig_add.dispatch( p );
		}
		
		private function removeParticle( i:int ):void
		{
			var p:Particle = _particles[i];
			
			_particles.splice( i, 1 );
			
			sig_remove.dispatch( p );
		}
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		protected var _particles:Vector.<Particle>;
		protected var _initializers:Vector.<Initializer>;
		protected var _actions:Vector.<Action>;
		protected var _creators:Vector.<Creator>;
	}
}