package engine.particle.actions
{
	import engine.particle.core.Action;
	import engine.particle.core.Emitter;
	import engine.particle.core.Particle;
	import engine.tween.TweenManager;
	
	/**
	 * TweenAction
	 * @author hbb
	 */
	public class TweenAction implements Action
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Mebmers
		[PBInject]
		public var tweenMgr:TweenManager;
		
		private var _props:Object;
		private var _params:Object;
		private var _particle:Particle;
		
		// ----------------------------------------------------------------
		// :: Getter/Setter
		
		// ----------------------------------------------------------------
		// :: Methods
		
		/**
		 * TweenAction
		 */
		public function TweenAction( props:Object, params:Object )
		{
			_props = props;
			_params = params;
			
			_params.onComplete = onComplete;
		}
		
		public function execute(p:Particle, time:Number, emitter:Emitter):void
		{
			if(_particle)
				return;
			
			_particle = p;
			tweenMgr.add( p, _props, _params );
		}
		
		private function onComplete():void
		{
			_particle.isDead = true;
		}
	}
}