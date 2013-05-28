package engine.particle.renderers
{
	import engine.particle.core.Particle;
	import engine.particle.core.Renderer;
	
	/**
	 * BaseRenderer
	 * @author hbb
	 */
	public class BaseRenderer implements Renderer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function BaseRenderer()
		{
		}
		
		public function addParticle(p:Particle):Boolean
		{
			_particles.push( p );
			return true;
		}
		
		public function removeParticle(p:Particle):Boolean
		{
			var i:int = _particles.indexOf( p );
			if( -1 == i )
				return false;
			
			_particles.splice( i, 1 );
			return true;
		}
		
		public function render():void
		{
		}
		
		public function destroy():void
		{
			for(var i:int = _particles.length - 1; i > -1; --i)
				this.removeParticle( _particles[i] );
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		protected var _particles:Vector.<Particle> = new Vector.<Particle>;
	}
}