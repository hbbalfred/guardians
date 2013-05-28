package engine.particle.creators
{
	import engine.particle.core.Creator;
	import engine.particle.core.Particle;
	
	/**
	 * CountCreator
	 * @author hbb
	 */
	public class CountCreator implements Creator
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		/**
		 * use millisecond instead of tick to interval unit
		 */
		public function set useTime( v:Boolean ):void
		{
			_useTime = v;
		}
		
		/**
		 * min creating interval, default unit is tick
		 */
		public function set minInterval( v:Number ):void
		{
			_minInterval = v;
		}
		
		/**
		 * max creating interval, default unit is tick
		 */
		public function set maxInterval( v:Number ):void
		{
			_maxInterval = v;
		}
		
		/**
		 * min number of particle in per creating 
		 */
		public function set minCountPerCreating( v:uint ):void
		{
			_minCountPerCreating = v;
		}
		/**
		 * max number of particle in per creating 
		 */
		public function set maxCountPerCreating( v:uint ):void
		{
			_maxCountPerCreating = v;
		}
		
		/**
		 * total number of particle creating 
		 */
		public function set totalCount( v:uint ):void
		{
			_totalCount = v;
		}
		
		/**
		 * delay to create 
		 */
		public function set delay( v:Number ):void
		{
			_delay = v;
		}
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function CountCreator(
			totalCount:uint = uint.MAX_VALUE,
			minInterval:Number = 0, maxInterval:Number = 0,
			minCountPerCreating:uint = 1, maxCountPerCreating:uint = 1,
			delay:Number = 0,
			userTime:Boolean = false
		)
		{
			this.useTime = userTime;
			this.minInterval = minInterval;
			this.maxInterval = maxInterval;
			this.minCountPerCreating = minCountPerCreating;
			this.maxCountPerCreating = maxCountPerCreating;
			this.totalCount = totalCount;
			this.delay = delay;
			
			_timer = 0;
			_currCount = 0;
		}
		
		public function get isActived():Boolean
		{
			return _currCount < _totalCount;
		}
		
		public function check( time:Number ):Boolean
		{
			if( !isActived )
				return false;
			
			if( _useTime )
				_timer += time;
			else
				++_timer;
			
			if( _delay >= _timer )
				return false;
			
			if( _interval >= _timer )
				return false;
			
			_delay = -1;
			_timer = 0;
			_interval = (_minInterval == _maxInterval )
				? _minInterval
				: _minInterval + Math.random() * (_maxInterval - _minInterval);
			return true;
		}
		
		public function create():Vector.<Particle>
		{
			var count:uint = (_minCountPerCreating == _maxCountPerCreating )
				? _minCountPerCreating
				: _minCountPerCreating + Math.random() * (_maxCountPerCreating - _minCountPerCreating);
			
			_currCount += count;
			
			var ret:Vector.<Particle> = new Vector.<Particle>;
			for(var i:int = 0; i < count; ++i)
			{
				ret[i] = new Particle;
			}
			
			return ret;
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		
		private var _minCountPerCreating:int;
		private var _maxCountPerCreating:uint;
		private var _minInterval:Number;
		private var _maxInterval:Number;
		private var _useTime:Boolean;
		private var _totalCount:uint;
		private var _delay:Number;
		
		private var _interval:Number;
		private var _timer:Number;
		
		private var _currCount:uint;
	}
}