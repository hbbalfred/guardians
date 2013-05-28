package engine.managers
{
	import engine.EngineContext;
	import engine.framework.core.IPBManager;
	import engine.framework.debug.Logger;
	import engine.utils.FunctionUtils;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;

	/**
	 * The SoundManager is a singleton that allows you to have various ways to control sounds in your project.
	 * <p />
	 * The SoundManager can load external sounds, play sounds loaded through an asset loader, or library sounds, 
	 * pause/mute/stop/control volume for one or more sounds at a time, fade sounds up or down, and allows additional 
	 * control to sounds not readily available through the default classes.
	 * <p />
	 * The supplementary SoundItem class is dependent on TweenLite (http://www.tweenlite.com) to aid in easily fading the volume of the sound.
	 * 
	 * @author Matt Przybylski [http://www.reintroducing.com]
	 * @author Tang Bo Hao
	 * @version 1.4
	 */
	public class SoundManager implements IPBManager
	{
		// Injection
		[PBInject] public var assetsMgr:AssetsManager;
		[PBInject] public var context:EngineContext;
		
		// Signal constants
		public const sig_SOUND_ITEM_ADDED:Signal = new Signal( String );
		public const sig_SOUND_ITEM_REMOVED:Signal = new Signal( String );
		public const sig_SOUND_ITEM_PAUSE:Signal = new Signal( String );
		public const sig_SOUND_ITEM_RESUME:Signal = new Signal( String );
		public const sig_SOUND_ITEM_STOP:Signal = new Signal( String );
		public const sig_SOUND_ITEM_PLAY_START:Signal = new Signal( String );
		public const sig_SOUND_ITEM_PLAY_COMPLETE:Signal = new Signal( String );
		public const sig_SOUND_ITEM_FADE:Signal = new Signal( String );
		public const sig_SOUND_ITEM_FADE_COMPLETE:Signal = new Signal( String );
		public const sig_REMOVED_ALL:Signal = new Signal();
		public const sig_PLAY_ALL:Signal = new Signal();
		public const sig_STOP_ALL:Signal = new Signal();
		public const sig_PAUSE_ALL:Signal = new Signal();
		public const sig_RESUME_ALL:Signal = new Signal();
		public const sig_MUTE_ALL:Signal = new Signal();
		public const sig_UNMUTE_ALL:Signal = new Signal();
		
		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------
		
		private var _soundsDict:Dictionary;
		private var _soundNameList:Vector.<String>;
		private var _areAllMuted:Boolean;
		
		
		//- CONSTRUCTOR	& DESTUCTOR --------------------------------------------------------------------------------
		public function initialize():void
		{	
			this._soundsDict = new Dictionary(true);
			this._soundNameList = new Vector.<String>;
		}
		
		public function destroy():void
		{
			unregisterAllSounds();
		}
		
		//- PRIVATE & PROTECTED METHODS ---------------------------------------------------------------------------
		
		/**
		 * parse sound 
		 * @param sndOrClass
		 * @return 
		 */
		private function parse( sndOrClass:* ):Sound
		{
			if( sndOrClass is Sound )
				return sndOrClass;
			
			if( sndOrClass is ByteArray )
			{
				var snd:Sound = new Sound;
				snd.loadCompressedDataFromByteArray( sndOrClass, sndOrClass.length );
				return snd;
			}
			
			if( sndOrClass is Class )
			{
				var instance:* = new sndOrClass();
				return parse( instance );
			}
			
			return null;
		}
		/**
		 * register a <code>SoundItem</code>
		 * @sndOrClass sound instance or sound class or binary sound-data class
		 * @name id
		 */
		private function registerSound( sndOrClass:*, name:String ):Boolean
		{
			// check to see if sound already exists by the specified name
			if( _soundsDict[name] )
				return false;
			
			var snd:Sound = parse( sndOrClass );
			
			if(!snd)
			{
				Logger.error(this, "registerSound", "Invalid sound type to register.");
				return false;
			}
			
			var si:SoundItem = new SoundItem( snd, name );
			// Inject Managers
			context.injectInto( si );
			
			si.volume = (_areAllMuted) ? 0 : 1;
			si.sig_PLAY_COMPLETE.add(handleSoundPlayComplete);
			
			_soundsDict[name] = si;
			_soundNameList.push(name);
			
			sig_SOUND_ITEM_ADDED.dispatch(name);
			
			return true;
		}
		
		/**
		 * Adds a sound from the library to the sounds dictionary for playing in the future.
		 * hides the getDefinitionByName call and apply the $linkageID as string identifier of the sound.
		 * @param className The class name of the library symbol that was exported for AS
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addSound(className:String):Boolean
		{
			return registerSound(getDefinitionByName(className), className);
		}
		
		/**
		 * Adds multiples sounds from the library to the sounds dictionary.
		 * 
		 * @param $collection The array containing each class name of the library symbol that was exported for AS.
		 * 
		 */
		public function addMultiplesSounds($collection:Array):void
		{
			for each( var name_str:String in $collection) {
				addSound(name_str);
			}
		}
		
		/**
		 * Adds a sound from the library to the sounds dictionary for playing in the future.
		 * 
		 * @param $linkageID The class name of the library symbol that was exported for AS
		 * @param $name The string identifier of the sound to be used when calling other methods on the sound
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addLibrarySound($class:Class, $name:String):Boolean
		{
			return registerSound($class, $name);
		}
		
		
		/**
		 * Adds a sound that was preloaded by an external library to the sounds dictionary for playing in the future.
		 * 
		 * @param $sound The sound object that was preloaded
		 * @param $name The string identifier of the sound to be used when calling other methods on the sound
		 * 
		 * @return Boolean A boolean value representing if the sound was added successfully
		 */
		public function addPreloadedSound($sound:Sound, $name:String):Boolean
		{
			return registerSound($sound, $name);
		}
		
		/**
		 * Removes a sound from the sound dictionary.  After calling this, the sound will not be available until it is re-added.
		 * 
		 * @param $name The string identifier of the sound to remove
		 * 
		 * @return void
		 */
		public function unregisterSound($name:String):void
		{
			if( !_soundsDict[$name] )
				return;
			
			var si:SoundItem = _soundsDict[$name];
			delete _soundsDict[$name];
			
			var i:int = _soundNameList.indexOf($name);
			_soundNameList.splice(i, 1);
			
			si.destroy();
			
			this.sig_SOUND_ITEM_REMOVED.dispatch( $name );
		}
		
		/**
		 * Removes all sounds from the sound dictionary.
		 * 
		 * @return void
		 */
		public function unregisterAllSounds():void
		{
			for(var name:String in _soundsDict)
			{
				unregisterSound( name );
			}
			
			_soundNameList = new Vector.<String>;
			_soundsDict = new Dictionary(true);
			
			this.sig_REMOVED_ALL.dispatch();
		}
		
		/**
		 * get sound by name 
		 * @param name
		 * @return 
		 * 
		 */
		public function getSoundItem(name:String):SoundItem
		{
			return _soundsDict[ name ];
		}
		
		/**
		 * check register the sound 
		 * @param name
		 * @return 
		 * 
		 */
		public function hasSoundItem(name:String):Boolean
		{
			return !!_soundsDict[ name ];
		}
		
		/**
		 * Beep Enable Trigger
		 */
		private var _beepEnable:Boolean = true;
		public function set beepEnable( value:Boolean ):void {	_beepEnable = value; }
		public function get beepEnable():Boolean {	return _beepEnable; }
		
		/**
		 *	This is a "fire and forget" kind of sound. This is to allow for the playback of a single sound
		 *	more then once, without having to create multiple copies of it. This is useful in the case of
		 *	a UI button click sound, which may be triggered several times quickly. 
		 */
		public function beep( $name:String, $volume:Number = 1, $startTime:Number = 0 ):void
		{
			if( !beepEnable )
				return;
			
			if( !hasSoundItem($name) ) {
				//silently fail
				Logger.error(this, "beep", new Error("The string identifier [" + $name + "] of the sound to play is not added").getStackTrace());
				return;
			}
			
			var si:SoundItem = getSoundItem($name);
			
			// bypass the SoundItem class, and just trigger the playback of the sound itself.
			si.sound.play($startTime, 0, new SoundTransform($volume));
		}
		
		
		/**
		 * Plays or resumes a sound from the sound dictionary with the specified name.  If the sounds in the dictionary were muted by 
		 * the muteAllSounds() method, no sounds are played until unmuteAllSounds() is called.
		 * 
		 * @param $name The string identifier of the sound to play
		 * @param $volume A number from 0 to 1 representing the volume at which to play the sound (default: 1)
		 * @param $startTime A number (in milliseconds) representing the time to start playing the sound at (default: 0)
		 * @param $loops An integer representing the number of times to loop the sound (default: 0)
		 * 
		 * @return void
		 */
		public function playSound($name:String, $volume:Number = 1, $startTime:Number = 0, $loops:int = 0):void
		{
			if( !hasSoundItem($name ) )
			{
				Logger.error(this, "playSound", new Error("The string identifier [" + $name + "] of the sound to play is not added").getStackTrace());
				return;
			}
			
			var si:SoundItem = getSoundItem($name);
			
			si.play($startTime, $loops, $volume);	
			
			this.sig_SOUND_ITEM_PLAY_START.dispatch( $name );
		}
		
		/**
		 * Stops the specified sound.
		 * 
		 * @param $name The string identifier of the sound
		 * 
		 * @return void
		 */
		public function stopSound($name:String):void
		{
			if( !hasSoundItem($name) )
			{
				Logger.error( this, "stopSound", new Error("The string identifier [" + $name + "] of the sound to stop is not added").getStackTrace());
				return;	
			}
			var si:SoundItem = getSoundItem($name);
			
			si.stop();
			
			this.sig_SOUND_ITEM_STOP.dispatch( $name );
		}
		
		/**
		 * Pauses the specified sound.
		 * 
		 * @param $name The string identifier of the sound
		 * @param $pauseTween A boolean that either pauses the fadeTween or allows it to continue (default: true)
		 * 
		 * @return void
		 */
		public function pauseSound($name:String):void
		{
			if( !hasSoundItem($name) )
			{
				Logger.error( this, "pauseSound", new Error("The string identifier [" + $name + "] of the sound to pause is not added").getStackTrace());
				return;
			}
			
			var si:SoundItem = getSoundItem($name);
			
			if( si.paused )
				return;
			
			si.pause();
			
			this.sig_SOUND_ITEM_PAUSE.dispatch( $name );
		}
		
		/**
		 * Resume the specified sound.
		 * 
		 * @param $name The string identifier of the sound
		 */
		public function resumeSound($name:String):void
		{
			if( !hasSoundItem($name) )
			{
				Logger.error( this, "resumeSound", new Error("The string identifier [" + $name + "] of the sound to resume is not added").getStackTrace());
				return;
			}
			
			var si:SoundItem = getSoundItem($name);
			
			if( !si.paused )
				return;
			
			si.resume();
			
			this.sig_SOUND_ITEM_RESUME.dispatch( $name );
		}
		
		
		/**
		 * Pauses all the sounds that are in the sound dictionary.
		 * 
		 * @return void
		 */
		public function pauseAllSounds():void
		{
			var len:int = _soundNameList.length;
			
			for (var i:int = 0;i < len;i++)
			{
				var name:String = _soundNameList[i];
				var si:SoundItem = getSoundItem(name);
				
				// flag the playing sound
				if( !si.paused )
				{
					si.pausedByAll = true;
					pauseSound( name );
				}
			}
			
			this.sig_PAUSE_ALL.dispatch();
		}
		
		/**
		 * Resume all the sounds that are in the sound dictionary.
		 * 
		 * @return void
		 */
		public function resumeAllSounds():void
		{
			var len:int = _soundNameList.length;
			
			for (var i:int = 0;i < len;i++)
			{
				var name:String = _soundNameList[i];
				var si:SoundItem = getSoundItem(name);
				
				if( si.pausedByAll )
				{
					resumeSound( name );
					si.pausedByAll = false;
				}
			}
			
			this.sig_RESUME_ALL.dispatch();
		}
		
		/**
		 * Stops all the sounds that are in the sound dictionary.
		 * 
		 * @return void
		 */
		public function stopAllSounds():void
		{
			var len:int = _soundNameList.length;
			
			for (var i:int = 0;i < len;i++) {
				var name:String = _soundNameList[i];
				stopSound(name);
			}
			
			this.sig_STOP_ALL.dispatch();
		}
		
		/**
		 * @deprecated
		 * 
		 * Fades the sound to the specified volume over the specified amount of time.
		 * 
		 * @param $name The string identifier of the sound
		 * @param $targVolume The target volume to fade to, between 0 and 1 (default: 0)
		 * @param $fadeLength The time to fade over, in seconds (default: 1)
		 * @param $stopOnComplete Added by Danny Miller from K2xL, stops the sound once the fade is done if set to true
		 * 
		 * @return void
		 */
		public function fadeSound($name:String, $targVolume:Number = 0, $fadeLength:Number = 1, $stopOnComplete:Boolean = false):void
		{
			var si:SoundItem = (_soundsDict[$name] as SoundItem);
			
			if(_soundsDict[$name] == null ) {
				//silently fail
				Logger.error( this, "fadeSound", new Error("The string identifier [" + $name + "] of the sound to fade is not added").getStackTrace());
				return;
			}
			
			si.sig_FADE_COMPLETE.addOnce( handleFadeComplete );
			si.fade($targVolume, $fadeLength, $stopOnComplete);
			
			this.sig_SOUND_ITEM_FADE.dispatch( $name );
		}
		
		/**
		 * Mutes the volume for all sounds in the sound dictionary.
		 * 
		 * @return void
		 */
		public function muteAllSounds():void
		{
			if( _areAllMuted )
				return;
			
			_areAllMuted = true;
			
			var len:int = _soundNameList.length;
			
			for (var i:int = 0;i < len;i++) {
				var name:String = _soundNameList[i];
				var si:SoundItem = getSoundItem(name);
				si.mute();
			}
			
			this.sig_MUTE_ALL.dispatch();
		}
		
		/**
		 * Resets the volume to their original setting for all sounds in the sound dictionary.
		 * 
		 * @return void
		 */
		public function unmuteAllSounds():void
		{
			if( !_areAllMuted )
				return;
			
			_areAllMuted = false;
			
			var len:int = _soundNameList.length;
			
			for (var i:int = 0;i < len;i++) {
				var name:String = _soundNameList[i];
				var si:SoundItem = getSoundItem(name);
				si.unmute();
			}
			
			this.sig_UNMUTE_ALL.dispatch();
		}
		
		
		//- EVENT HANDLERS ----------------------------------------------------------------------------------------
		
		/**
		 * Dispatched once a sound's fadeTween is completed if the sound was called to fade.
		 */
		private function handleFadeComplete(si:SoundItem):void
		{
			this.sig_SOUND_ITEM_FADE_COMPLETE.dispatch(si.name);
		}
		
		/**
		 * Dispatched when a SoundItem has finished playback.
		 */
		private function handleSoundPlayComplete(si:SoundItem):void
		{
			this.sig_SOUND_ITEM_PLAY_COMPLETE.dispatch(si.name);
		}
		
		//- GETTERS & SETTERS -------------------------------------------------------------------------------------
		
		/**
		 * read-only is all sounds muted
		 */
		public function get areAllMuted():Boolean
		{
			return _areAllMuted;
		}
		
		//- END CLASS ---------------------------------------------------------------------------------------------
	}
}