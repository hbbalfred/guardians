package engine.particle.actions
{
	import flash.display.MovieClip;
	
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	
	/**
	 * PlayOnce
	 * @author hbb
	 */
	public class PlayOnceAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			if( p.display is MovieClip )
			{
				var mc:MovieClip = p.display;
				p.isDead = (mc.currentFrame == mc.totalFrames && mc.totalFrames > 0);
			}
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}