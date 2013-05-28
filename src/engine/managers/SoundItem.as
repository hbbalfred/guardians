package engine.managers
{
	import engine.tween.TweenManager;
	import engine.tween.ZTween;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osflash.signals.Signal;

	/**
	 * @author Matt Przybylski [http://www.reintroducing.com]
	 * @version 1.2
	 */
	public class SoundItem
	{
		// ----- Injection ------
		[PBInject] public var tweenMgr:TweenManager;
		
		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------
		
		protected var _fadeTween:ZTween;
		protected var _volume:Number = 0;
		protected var _paused:Boolean = true;
		protected var _position:int = 0;
		protected var _loops:int = 0;
		protected var _startTime:Number = 0.0;
		protected var _name:String;
		protected var _channel:SoundChannel;
		
		private var _volumeAtMuted:Number = -1;
		private var _loopCount:int = 0;
		
		//- PUBLIC & INTERNAL VARIABLES ---------------------------------------------------------------------------
		
		internal var sound:Sound;
		internal var pausedByAll:Boolean;
		
		// Signals
		public const sig_PLAY_COMPLETE:Signal = new Signal(SoundItem);
		public const sig_FADE_COMPLETE:Signal = new Signal(SoundItem);
		
		//- CONSTRUCTOR	-------------------------------------------------------------------------------------------
		
		public function SoundItem( snd:Sound, name:String ):void
		{
			sound = snd;
			_name = name;
			init();
		}
		
		//- PRIVATE & PROTECTED METHODS ---------------------------------------------------------------------------
		
		/**
		 * initialize
		 */
		private function init():void
		{
			_channel = new SoundChannel();
		}
		
		//- PUBLIC & INTERNAL METHODS -----------------------------------------------------------------------------
		
		/**
		 * Plays the sound item.
		 * 
		 * @param $startTime The time, in seconds, to start the sound at (default: 0)
		 * @param $loops The number of times to loop the sound (default: 0)
		 * @param $volume The volume to play the sound at (default: 1)
		 * @param $resumeTween If the sound volume is faded and while fading happens the sound is stopped, this will resume that fade tween (default: true)
		 * 
		 * @return void
		 */
		public function play($startTime:Number = 0, $loops:int = 0, $volume:Number = 1):void
		{
			if(!_paused)
				stop();
			
			_loops = $loops;
			_startTime = $startTime;
			_position = $startTime;
			_paused = false;
			pausedByAll = false;
			_loopCount = 0;
			
			_channel = sound.play(_position, 0);
			// prevent sound channel over to the max aviable number
			if(!_channel)
			{
				stop();
				return;
			}
			_channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			
			volume = $volume;
		}
		
		/**
		 * Stops the sound item.
		 */
		public function stop():void
		{
			pausedByAll = false;
			_paused = true;
			_position = _startTime;
			if(_channel)
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
				_channel.stop();
			}
		}
		
		/**
		 * resume the sound item 
		 */
		public function resume():void
		{
			if(!_paused)
				return;
			
			_paused = false;
			_channel = sound.play(_position, 0, new SoundTransform(_volume));
			// prevent sound channel over to the max aviable number
			if(!_channel)
			{
				stop();
				return;
			}
			_channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
		}
		
		/**
		 * Pauses the sound item.
		 * 
		 * @param $pauseTween If a fade tween is happening at the moment the sound is paused, the tween will be paused as well (default: true)
		 * 
		 * @return void
		 */
		public function pause():void
		{
			if(_paused)
				return;
			
			_paused = true;
			_position = _channel.position;
			_channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			_channel.stop();
		}
		
		/**
		 * Fades the sound item.
		 * 
		 * @param $volume The volume to fade to (default: 0)
		 * @param $fadeLength The time, in seconds, to fade the sound (default: 1)
		 * @param $stopOnComplete Stops the sound once the fade is completed (default: false)
		 * 
		 * @return void
		 */
		public function fade($volume:Number = 0, $fadeLength:Number = 1, $stopOnComplete:Boolean = false):void
		{
			// TODO
		}
		
		/**
		 * Sets the volume of the sound item.
		 * 
		 * @param $volume The volume, from 0 to 1, to set
		 * @param ignoreMuteSetting
		 * 
		 * @return void
		 */
		protected function setVolume($volume:Number):void
		{
			_volume = $volume;
			
			var curTransform:SoundTransform = _channel.soundTransform;
			curTransform.volume = _volume;
			_channel.soundTransform = curTransform;
		}
		
		/**
		 * mute the sound 
		 */
		public function mute():void
		{
			if( _volumeAtMuted == -1 ){
				_volumeAtMuted = _volume;
				setVolume(0);	
			}
		}
		
		/**
		 * unmute the sound 
		 */
		public function unmute():void
		{
			if( _volumeAtMuted >= 0 ){
				setVolume(_volumeAtMuted);
				_volumeAtMuted = -1;
			}
		}
		
		/**
		 * Clears the sound item for garbage collection.
		 * 
		 * @return void
		 */
		public function destroy():void
		{
			sig_PLAY_COMPLETE.removeAll();
			sig_FADE_COMPLETE.removeAll();
			stop();
			_channel = null;
		}
		
		//- EVENT HANDLERS ----------------------------------------------------------------------------------------
		
		/**
		 *
		 */
		private function handleSoundComplete($evt:Event):void
		{
			if( ++_loopCount > _loops )
			{
				stop();
				sig_PLAY_COMPLETE.dispatch(this);
			}
			else
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
				_channel = sound.play(_startTime, 0, new SoundTransform(_volume));
				// prevent sound channel over to the max aviable number
				if(!_channel)
				{
					stop();
					return;
				}
				_channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			}
		}
		
		//- GETTERS & SETTERS -------------------------------------------------------------------------------------
		
		/**
		 * the current volume.
		 */
		public function get volume():Number{ return _volume; }
		public function set volume($val:Number):void
		{
			if( _volumeAtMuted == -1 ){
				setVolume($val);	
			}else{
				setVolume(0);
			}
		}
		
		/**
		 * read-only loop counts 
		 */
		public function get loops():int{ return _loops; }
		public function set loops(v:int):void
		{
			_loops = v;
		}
		
		/**
		 * read-only the sound is paused.
		 */
		public function get paused():Boolean{ return _paused; }
		
		/**
		 * read-only the position of sound playing. 
		 */
		public function get position():int{ return _position; }
		
		/**
		 * read-only the length of sound. 
		 */
		public function get duration():int{ return sound.length; }
		
		/**
		 * read-only name of sound item. 
		 */
		public function get name():String{ return _name; }
		
		/**
		 * read-only sound is muted. 
		 */
		public function get muted():Boolean{ return _volume == 0; }
		
		//- END CLASS ---------------------------------------------------------------------------------------------
	}
}