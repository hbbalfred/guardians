package engine.tween {
	import engine.framework.time.TimeManager;

	/**
	 * @author Zeh Fernando
	 */
	public class ZTween {
		
		[PBInject] public var tweenMgr:TweenManager;
		[PBInject] public var timeMgr:TimeManager;

		/*
		Versions
		1.4.3	2011-05-23	added: updateTime()
		1.3.3	2010-12-17	fixed: ZTweenSignal.remove() was not checking properly if a signal existed properly (thanks to github.com/hankpillow)
		1.3.2	2010-09-07	fixed: stupid bug on onStart/onComplete/onUpdate getter/setters
		1.3.1				added onStartParams, onUpdateParams, onCompleteParams
		1.2.1				signals now have getters
		1.2.0				using signals for onStart/onUpdate/onComplete
		1.1.0				made the secondary parameters (time, transition, delay) into an object
		1.0.0
		*/

		// Properties
		protected var _target					:Object;		// Object affected by this tweening
		protected var _properties				:Vector.<ZTweenProperty>;		// List of properties that are tweened
		protected var numProps					:int;
		protected var _param					:Object;		// Temp save for parameters

		protected var timeStart					:int;			// Time when this tweening should start
		protected var timeCreated				:int;			// Time when this tweening was created
		protected var timeComplete				:int;			// Time when this tweening should end
		protected var timeDuration				:int;			// Time this tween takes (cache)
		protected var transition				:Function;		// Equation to control the transition animation
		//private var transitionParams			:Object;		// Additional parameters for the transition
		//private var rounded					:Boolean;		// Use rounded values when updating
		protected var timePaused				:int;			// Time when this tween was paused
		//private var skipUpdates				:uint;			// How many updates should be skipped (default = 0; 1 = update-skip-update-skip...)
		//private var updatesSkipped			:uint;			// How many updates have already been skipped
		protected var started					:Boolean;		// Whether or not this tween has already started executing

		protected var _onStart					:ZTweenSignal;
		protected var _onUpdate					:ZTweenSignal;
		protected var _onComplete				:ZTweenSignal;

		// External properties
		protected var _paused					:Boolean;		// Whether or not this tween is currently paused
		protected var _useFrames				:Boolean;		// Whether or not to use frames instead of seconds

		// Temporary variables to avoid disposal
		protected var t							:Number;		// Current time (0-1)
		protected var tProperty					:ZTweenProperty;	// Property being checked
		protected var pv						:Number;		// Property value
		protected var i							:int;			// Loop iterator
		protected var cTime						:int;			// Current engine time (in frames or seconds)

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		/**
		 * Creates a new Tween.
		 *
		 * @param	p_scope				Object		Object that this tweening refers to.
		 */
		public function ZTween(__target:Object, __properties:Object = null, __parameters:Object = null) {

			_target				=	__target;

			_properties			=	new Vector.<ZTweenProperty>();
			for (var pName:String in __properties) {
				_properties.push(new ZTweenProperty(pName, __properties[pName]));
				//addProperty(pName, __properties[pName]);
			}
			numProps = _properties.length;
			
			_param = __parameters;
		}
		
		/**
		 * Initialize will be called with injection members
		 */		
		public function initialize():void{
			_useFrames = Boolean(_param && _param["useFrames"]);
			
			timeCreated			=	_useFrames ? tweenMgr.currentTimeFrame : tweenMgr.currentTime;
			timeStart			=	timeCreated;

			// Parameters
			time				=	0;
			delay				=	0;
			transition			=	Equations.none;

			_onStart			=	new ZTweenSignal();
			_onUpdate			=	new ZTweenSignal();
			_onComplete			=	new ZTweenSignal();

			// Read parameters
			if (Boolean(_param)) {
				
				pv = _param["time"];
				if (pv is Number && !isNaN(pv)) time = pv;

				pv = _param["delay"];
				if (pv is Number && !isNaN(pv)) delay = pv;

				if (Boolean(_param["transition"])) transition = _param["transition"];

				if (Boolean(_param["onStart"])) _onStart.add(_param["onStart"], _param["onStartParams"]);
				if (Boolean(_param["onUpdate"])) _onUpdate.add(_param["onUpdate"], _param["onUpdateParams"]);
				if (Boolean(_param["onComplete"])) _onComplete.add(_param["onComplete"], _param["onCompleteParams"]);
			}
			//transitionParams	=	new Array();

			_paused				=	false;
			//skipUpdates		=	0;
			//updatesSkipped	=	0;
			started				=	false;
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function updateCache(): void {
			timeDuration = timeComplete - timeStart;
		}



		// ================================================================================================================
		// PUBLIC INSTANCE functions --------------------------------------------------------------------------------------

		// Event interceptors for caching
		public function update(currentTime:int, currentTimeFrame:int): Boolean {

			if (_paused) return true;

			cTime = _useFrames ? currentTimeFrame : currentTime;

			if (started || cTime >= timeStart) {
				if (!started) {
					_onStart.dispatch();

					for (i = 0; i < _properties.length; i++) {
						// Property value not initialized yet
						tProperty = ZTweenProperty(_properties[i]);

						// Directly read property
						pv = _target[tProperty.name];

						tProperty.valueStart = isNaN(pv) ? tProperty.valueComplete : pv; // If the property has no value, use the final value as the default
						tProperty.valueChange = tProperty.valueComplete - tProperty.valueStart;
					}
					started = true;
				}

				if (cTime >= timeComplete) {
					// Tweening time has finished, just set it to the final value
					for (i = 0; i < _properties.length; i++) {
						tProperty = ZTweenProperty(_properties[i]);
						_target[tProperty.name] = tProperty.valueComplete;
					}

					_onUpdate.dispatch();

					// call on Complete at next tick
					timeMgr.callLater( _onComplete.dispatch );

					return false;

				} else {
					// Tweening must continue
					t = transition((cTime - timeStart) / timeDuration);
					for (i = 0; i < numProps; i++) {
						tProperty = ZTweenProperty(_properties[i]);
						_target[tProperty.name] = tProperty.valueStart + t * tProperty.valueChange;
					}

					_onUpdate.dispatch();
				}

			}

			return true;

		}

		public function pause(): void {
			if (!_paused) {
				_paused = true;
				timePaused = _useFrames ? tweenMgr.currentTimeFrame: tweenMgr.currentTime;
			}
		}

		public function resume(): void {
			if (_paused) {
				_paused = false;
				var timeNow:Number = _useFrames ? tweenMgr.currentTimeFrame: tweenMgr.currentTime;
				timeStart += timeNow - timePaused;
				timeComplete += timeNow - timePaused;
			}
		}


		// ==================================================================================================================================
		// ACESSOR functions ----------------------------------------------------------------------------------------------------------------

		public function get delay(): Number {
			return (timeStart - timeCreated) / (_useFrames ? 1 : 1000);
		}

		public function set delay(__value:Number): void {
			timeStart = timeCreated + (__value * (_useFrames ? 1 : 1000));
			timeComplete = timeStart + timeDuration;
			//updateCache();
			// TODO: take pause into consideration!
		}

		public function get time(): Number {
			return (timeComplete - timeStart) / (_useFrames ? 1 : 1000);
		}

		public function set time(__value:Number): void {
			timeComplete = timeStart + (__value * (_useFrames ? 1 : 1000));
			updateCache();
			// TODO: take pause into consideration!
		}

		public function get paused(): Boolean {
			return _paused;
		}

		/*
		public function set paused(p_value:Boolean): void {
			if (p_value == _paused) return;
			_paused = p_value;
			if (paused) {
				// pause
			} else {
				// resume
			}
		}
		*/

		public function get useFrames(): Boolean {
			return _useFrames;
		}

//		public function set useFrames(__value:Boolean): void {
//			var tDelay:Number = delay;
//			var tTime:Number = time;
//			_useFrames = __value;
//			timeStart = _useFrames ? tweenMgr.currentTimeFrame: tweenMgr.currentTime;
//			delay = tDelay;
//			time = tTime;
//		}

		public function get target():Object {
			return _target;
		}
		public function set target(target:Object):void {
			_target = target;
		}
		
		public function get properties():Vector.<ZTweenProperty>{
			return _properties;
		}

		public function get onStart(): ZTweenSignal {
			return _onStart;
		}
		public function get onUpdate(): ZTweenSignal {
			return _onUpdate;
		}
		public function get onComplete(): ZTweenSignal {
			return _onComplete;
		}
	}
}
