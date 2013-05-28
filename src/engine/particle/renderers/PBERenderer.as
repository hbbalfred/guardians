package engine.particle.renderers
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import engine.framework.core.PBGameObject;
	import engine.particle.core.Particle;
	import engine.render2D.BitmapRenderer;
	import engine.render2D.DisplayObjectRenderer;
	import engine.render2D.MovieClipRenderer;
	
	/**
	 * PBERenderer
	 * @author hbb
	 */
	public class PBERenderer extends BaseRenderer
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function PBERenderer( owner:PBGameObject, layerIndex:int = -1, initForRenderer:Object = null )
		{
			_owner = owner;
			_layerIndex = layerIndex;
			_initForRenderer = initForRenderer;
			
			_dict = new Dictionary;
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
			{
				var r:DisplayObjectRenderer;
				if( p.display is MovieClip )
					r = new MovieClipRenderer;
				else if( p.display is BitmapData )
					r = new BitmapRenderer;
				else
					r = new DisplayObjectRenderer;
				
				if( _layerIndex > 0 )
					r.layerIndex = _layerIndex;
				
				if( _initForRenderer )
					for(var i:String in _initForRenderer)
						if(i in r )
							r[i] = _initForRenderer[i];
				
				if( r is BitmapRenderer )
					BitmapRenderer(r).bitmapData = p.display;
				else
					r.displayObject = p.display;
				
				_dict[p] = r;
				_owner.addComponent( r, "particle_renderer_" + _particles.length );
				
				r.onFrame();
			}
			
			return ret;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function removeParticle( p:Particle ):Boolean
		{
			var ret:Boolean = super.removeParticle( p );
			
			if(ret)
			{
				if( _dict[p].owner == _owner )
					_owner.removeComponent( _dict[p] );
				delete _dict[p];
			}
			
			return ret;
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function render():void
		{
			var pt:Point = new Point;
			var r:DisplayObjectRenderer;
			var p:Particle;
			var n:int = _particles.length;
			for( var i:int = 0; i < n; ++i )
			{
				p = _particles[i];
				r = _dict[p];
				
				pt.x = p.x;
				pt.y = p.y;
				
				r.position = pt;
				r.rotation = p.rotation;
				r.zIndex = p.zIndex;
				
				r.body.scaleX = p.scaleX;
				r.body.scaleY = p.scaleY;
				
				_ct.redMultiplier = p.rmul;
				_ct.greenMultiplier = p.gmul;
				_ct.blueMultiplier = p.bmul;
				_ct.redOffset = p.roff;
				_ct.greenOffset = p.goff;
				_ct.blueOffset = p.boff;
				_ct.alphaMultiplier = p.alpha;
				
				r.body.transform.colorTransform = _ct; 
			}
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _dict:Dictionary;
		private var _owner:PBGameObject;
		private var _layerIndex:int;
		private var _initForRenderer:Object;
		
		private var _ct:ColorTransform = new ColorTransform;
	}
}