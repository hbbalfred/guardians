package engine.particle.core
{
	/**
	 * Particle
	 * @author hbb
	 */
	public class Particle
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		public var x:Number;
		public var y:Number;
		public var scaleX:Number;
		public var scaleY:Number;
		public var width:Number;
		public var height:Number;
		/**
		 * unit is radians 
		 */
		public var rotation:Number;
		public var alpha:Number;
		public var rmul:Number;
		public var gmul:Number;
		public var bmul:Number;
		public var roff:Number;
		public var goff:Number;
		public var boff:Number;
		
		public var vx:Number;
		public var vy:Number;
		public var vscaleX:Number;
		public var vscaleY:Number;
		public var vwidth:Number;
		public var vheight:Number;
		/**
		 * unit is radians 
		 */
		public var vrotation:Number;
		public var valpha:Number;
		public var vrmul:Number;
		public var vgmul:Number;
		public var vbmul:Number;
		public var vroff:int;
		public var vgoff:int;
		public var vboff:int;
		
		public var zIndex:Number;
		public var display:*;
		
		public var isDead:Boolean;
		public var lifecycle:Number;
		public var lifecycleMax:Number;
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function Particle()
		{
			init();
		}
		
		public function clone():Particle
		{
			var p:Particle = new Particle;
			p.copy( this );
			return p;
		}
		
		public function copy( p:Particle ):void
		{
			x = p.x;
			y = p.y;
			scaleX = p.scaleX;
			scaleY = p.scaleY;
			width = p.width;
			height = p.height;
			rotation = p.rotation;
			alpha = p.alpha;
			rmul = p.rmul;
			gmul = p.gmul;
			bmul = p.bmul;
			roff = p.roff;
			goff = p.goff;
			boff = p.boff;
			
			vx = p.vx;
			vy = p.vy;
			vscaleX = p.vscaleX;
			vscaleY = p.vscaleY;
			vwidth = p.vwidth;
			vheight = p.vheight;
			vrotation = p.vrotation;
			valpha = p.valpha;
			vrmul = p.vrmul;
			vgmul = p.vgmul;
			vbmul = p.vbmul;
			vroff = p.vroff;
			vgoff = p.vgoff;
			vboff = p.vboff;
			
			zIndex = p.zIndex;
			display = p.display;
			
			isDead = p.isDead;
			lifecycle = p.lifecycle;
			lifecycleMax = p.lifecycleMax;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		protected function init():void
		{
			x = y = rotation = width = height = 0;
			scaleX = scaleY = alpha = 1;
			isDead = false;
			zIndex = 0;
			lifecycle = 0;
			lifecycleMax = 0;
			
			rmul = gmul = bmul = 1.0;
			roff = goff = boff = 0;
			
			vx = vy = vscaleX = vscaleY = vrotation = valpha = 0;
			vrmul = vgmul = vbmul = vroff = vgoff = vboff = 0;
		}
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}