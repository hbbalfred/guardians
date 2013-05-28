package engine.particle.renderers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	
	import engine.particle.core.Particle;
	import engine.utils.MathUtils;
	
	/**
	 * DisplayObjectRenderer
	 * @author hbb
	 */
	public class IDERenderer extends BaseRenderer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * DisplayObjectRenderer 
		 * @param container
		 */
		public function IDERenderer( container:DisplayObjectContainer )
		{
			_container = container;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		/**
		 * @inheritDoc 
		 */
		override public function addParticle( p:Particle ):Boolean
		{
			var ret:Boolean = super.addParticle( p );
			
			if(ret)
				_container.addChild( p.display );
			
			return ret;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function removeParticle( p:Particle ):Boolean
		{
			var ret:Boolean = super.removeParticle( p );
			
			if(ret)
				_container.removeChild( p.display );
			
			return ret;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function render():void
		{
			var e:DisplayObject;
			var p:Particle;
			var n:int = _particles.length;
			for( var i:int = 0; i < n; ++i )
			{
				p = _particles[i];
				e = p.display;
				
				e.x = p.x;
				e.y = p.y;
				e.scaleX = p.scaleX;
				e.scaleY = p.scaleY;
				e.rotation = MathUtils.getDegreesFromRadians( p.rotation );
				
				_ct.redMultiplier = p.rmul;
				_ct.greenMultiplier = p.gmul;
				_ct.blueMultiplier = p.bmul;
				_ct.redOffset = p.roff;
				_ct.greenOffset = p.goff;
				_ct.blueOffset = p.boff;
				_ct.alphaMultiplier = p.alpha;
				
				e.transform.colorTransform = _ct; 
			}
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _container:DisplayObjectContainer;
		private var _ct:ColorTransform = new ColorTransform;
	}
}