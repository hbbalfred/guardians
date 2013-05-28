package engine.tween
{
	import engine.EngineContext;
	import engine.framework.core.IPBManager;
	import engine.framework.time.IAnimated;
	import engine.framework.time.TimeManager;
	
	/**
	 * ZTween Manager to replace static function
	 * @author Tang Bo Hao
	 */
	public class TweenManager implements IPBManager,IAnimated
	{	
		[PBInject] public var timeMgr:TimeManager;
		[PBInject] public var context:EngineContext;
		
		// properties
		public var currentTime:Number;					// The current time. This is generic for all tweenings for a "time grid" based update
		public var currentTimeFrame:uint;				// The current frame. Used on frame-based tweenings
		
		protected var tweens:Vector.<ZTween> = new Vector.<ZTween>();				// List of active tweens
		
		// Temp vars
		protected var i:uint;
		protected var l:uint;

		/**
		 * @inhertedDoc
		 */
		public function initialize():void
		{			
			currentTimeFrame = timeMgr.frameCounter;
			currentTime = timeMgr.virtualTime;

			timeMgr.addAnimatedObject( this, Number.MAX_VALUE );
		}
		
		/**
		 * @inhertedDoc
		 */
		public function destroy():void
		{
			timeMgr.removeAnimatedObject( this );
		}
		
		/**
		 * Ran once every frame. It's the main engine; updates all existing tweenings.
		 */
		public function onFrame():void
		{
			// Update time
			currentTime = timeMgr.virtualTime;
			
			// Update frame
			currentTimeFrame = timeMgr.frameCounter;
			
			// Update all tweens
			updateTweens();
		}
		
		// ==================================================================================================================================
		// ENGINE functions -----------------------------------------------------------------------------------------------------------------
		
		/**
		 * Updates all existing tweenings.
		 */
		protected function updateTweens(): void {
			
			l = tweens.length;
			for (i = 0; i < l; i++) { // ++i had no impact, must test more
				if (!Boolean(tweens[i]) || !tweens[i].update(currentTime, currentTimeFrame)) {
					tweens.splice(i, 1);
					i--;
					l--;
				}
			}
		}
		
		// ================================================================================================================
		// PUBLIC STATIC functions ----------------------------------------------------------------------------------------
		
		/**
		 * Create a new tweening for an object and starts it.
		 */
		public function add(tar:Object, prop:Object = null, parameters:Object = null): ZTween {
			var t:ZTween = new ZTween(tar, prop, parameters);
			context.injectInto( t ); // Inject TweenManager
			t.initialize();
			
			tweens.push(t);
			return t;
		}
		
		public function remove(tar:Object, ...__props): Boolean {
			// TODO: mark for removal, but don't remove immediately
			//var tl:Vector.<ZTween> = getTweens(__target, __props);
			
			var tl:Vector.<ZTween> = new Vector.<ZTween>();
			
			var l:int = tweens.length;
			var i:int;
			var j:int;
			// TODO: use filter?
			
			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i].target == tar) {
					if (__props.length > 0) {
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								tweens[i].properties.splice(j, 1);
								j--;
							}
						}
						if (tweens[i].properties.length == 0) tl.push(tweens[i]);
					} else {
						tl.push(tweens[i]);
					}
				}
			}
			
			var removedAny:Boolean;
			
			l = tl.length;
			
			for (i = 0; i < l; i++) {
				j = tweens.indexOf(tl[i]);
				removeTweenByIndex(j);
				removedAny = true;
			}
			
			return removedAny;
		}
		
		public function hasTween(tar:Object, ...__props): Boolean {
			//return (getTweens.apply(([__target] as Array).concat(__props)) as Vector.<ZTween>).length > 0;
			
			var l:int = tweens.length;
			var i:int;
			var j:int;
			// TODO: use filter?
			
			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i].target == tar) {
					if (__props.length > 0) {
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								return true;
							}
						}
					} else {
						return true;
					}
				}
			}
			
			return false;
			
		}
		
		public function getTweens(__target:Object, ...__props): Vector.<ZTween> {
			var tl:Vector.<ZTween> = new Vector.<ZTween>();
			
			var l:int = tweens.length;
			var i:int;
			var j:int;
			var found:Boolean = false;
			// TODO: use filter?
			
			//trace ("ZTween :: getTweens() :: getting tweens for "+__target+", "+__props+" ("+__props.length+" properties)");
			
			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i].target == __target) {
					if (__props.length > 0) {
						found = false;
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								found = true;
								break;
							}
						}
						if (found) tl.push(tweens[i]);
					} else {
						tl.push(tweens[i]);
					}
				}
			}
			
			return tl;
		}
		
		public function pause(tar:Object, ...__props): Boolean {
			var pausedAny:Boolean = false;
			
			var ftweens:Vector.<ZTween> = getTweens.apply(null, [tar].concat(__props));
			var i:int;
			
			//trace ("ZTween :: pause() :: pausing tweens for " + __target + ": " + ftweens.length + " actual tweens");
			
			// TODO: use filter/apply?
			for (i = 0; i < ftweens.length; i++) {
				if (!ftweens[i].paused) {
					ftweens[i].pause();
					pausedAny = true;
				}
			}
			
			return pausedAny;
		}
		
		public function resume(tar:Object, ...__props): Boolean {
			var resumedAny:Boolean = false;
			
			var ftweens:Vector.<ZTween> = getTweens.apply(null, [tar].concat(__props));
			var i:int;
			
			// TODO: use filter/apply?
			for (i = 0; i < ftweens.length; i++) {
				if (ftweens[i].paused) {
					ftweens[i].resume();
					resumedAny = true;
				}
			}
			
			return resumedAny;
		}
		
		/**
		 * Remove a specific tweening from the tweening list.
		 *
		 * @param		p_tween				Number		Index of the tween to be removed on the tweenings list
		 * @return							Boolean		Whether or not it successfully removed this tweening
		 */
		public function removeTweenByIndex(__i:Number): void {
			//__finalRemoval:Boolean = false
			tweens[__i] = null;
			//if (__finalRemoval) tweens.splice(__i, 1);
			//tweens.splice(__i, 1);
			//return true;
		}
	}
}