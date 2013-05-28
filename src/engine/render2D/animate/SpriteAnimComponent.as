package engine.render2D.animate
{
	import flash.utils.Dictionary;
	
	import engine.framework.time.TickedComponent;
	import engine.render2D.spritesheet.SpriteSheetManager;
	import engine.utils.ArrayUtils;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Sprite Animation Component 
	 * @author hbb
	 */
	public class SpriteAnimComponent extends TickedComponent
	{
		[PBInject] public var ssm:SpriteSheetManager;
		
		public const sig_complete:Signal = new Signal;
		public const sig_keyFrame:Signal = new Signal(String); // frame label
		
		protected var _anims:Dictionary;
		protected var _cur:*;
		 
		/**
		 * current animation name 
		 */
		public function get currentAnimName():String
		{
			var anim:AnimDef = currentAnim;
			if(anim)
				return anim.name;
			return "";
		}
		/**
		 * current animation used sprite sheet 
		 */
		public function get currentSpriteSheetID():String
		{
			var anim:AnimDef = currentAnim;
			if(anim)
				return anim.spriteSheetID;
			return "";
		}
		/**
		 * current animation playing frame 
		 */
		public function get currentFrame():int
		{
			var anim:AnimDef = currentAnim;
			if(!anim)
				return 0;
			var frame:int = Math.min( anim.curTick / anim.tickTimes,  anim.frameIndices.length - 1 );
			return anim.frameIndices[ frame ];
		}
		
		/**
		 * create animation
		 * default loop is false
		 * 
		 * @param name, animation name in general it is a string
		 * @param sheetID, id of the sprite sheet for animation using 
		 * @param frames, the specific frame indices of sprite sheet in this animation, default is all
		 */
		public function create( name:*, sheetID:String, frames:Array = null ):void
		{
			if( !frames )
				frames = ArrayUtils.generateNumberArray( ssm.getSpriteSheetByID( sheetID ).totalFrames );
			
			if( !_anims )
				_anims = new Dictionary();
			
			var anim:AnimDef = _anims[ name ] = new AnimDef();
			anim.name = name;
			anim.spriteSheetID = sheetID;
			anim.frameIndices = Vector.<int>(frames);
			
			// clear for some odd case
			if( _cur == name )
				_cur = null;
		}
		
		/**
		 * determine the specific animation whether playing or not 
		 * @param name
		 */
		public function isPlaying( name:* ):Boolean
		{
			if(!name) return false;
			return _cur == name;
		}
		
		/**
		 * play an animation 
		 * @param name, animation id in general it is a string
		 * @param tickTimes, how much ticks use in every frame of animation
		 * @param repeat, count of repeat animation, -1 value is loop
		 */
		public function play( name:*, tickTimes:int, repeat:int = 0 ):void
		{
			if( _cur == name ) return;
			
			var anim:AnimDef = _anims[ _cur = name ];
			if(!anim) return;
			anim.tickTimes = tickTimes;
			anim.curTick = 0;
			anim.totalTicks = tickTimes * anim.frameIndices.length;
			anim.repeat = repeat;
			anim.loop = repeat == -1;
		}
		
		/**
		 * stop the current animation 
		 */
		public function stop():void
		{
			_cur = null;
		}
		
		/**
		 * add a key frame for 
		 * @param name, animation name
		 * @param frame, key frame, start base by 0
		 * @param label, frame label
		 */
		public function addKeyFrame( name:String, frame:int, label:String ):void
		{
			if( !_anims[ name ] )
				throw new ArgumentError("Error: no animation '" + anim + "'");
			
			var anim:AnimDef = _anims[name];
			if( frame < 0 )
				frame += anim.frameIndices.length;
			if( frame > anim.frameIndices.length - 1 )
				frame = anim.frameIndices.length - 1;
			
			anim.keyframes[frame] = label;
		}
		
		/**
		 * @inheritDoc 
		 */
		override protected function doTick():void
		{
			if( !_anims ) return;
			
			var anim:AnimDef = _anims[ _cur ];
			
			if( !anim ) return;
			
			// on key frame
			if( anim.curTick % anim.tickTimes == 0 )
			{
				doKeyFrame();
			}
			
			// play to the last frame
			if( ++anim.curTick == anim.totalTicks )
			{
				// continue to playing
				if( anim.loop || anim.repeat > 0 )
				{
					if(anim.repeat > 0) --anim.repeat;
					anim.curTick = 0;
				}
				else
				{
					stop();
					onAnimationComplete();
				}
			}
		}
		
		/**
		 * handle key frame 
		 */
		protected function doKeyFrame():void
		{
			if( sig_keyFrame.numListeners == 0 ) return;
			if( currentAnim.keyframes.length == 0 ) return;
			
			var label:String = currentAnim.keyframes[ currentFrame ];
			if( !label ) return;
			
			sig_keyFrame.dispatch( label );
		}
		
		/**
		 * @inheritDoc 
		 */
		protected override function onRemove():void
		{
			for(var name:* in _anims)
				delete _anims[name];
			_anims = null;
			_cur = null;
			
			sig_complete.removeAll();
			sig_keyFrame.removeAll();
			
			super.onRemove();
		}
		
		/**
		 * @private
		 * event on animation end 
		 */
		protected function onAnimationComplete():void
		{
			// think about dispatch a signal
			if(sig_complete.numListeners > 0)
				sig_complete.dispatch();
		}
		
		/**
		 * @private
		 * current animation 
		 */
		protected function get currentAnim():AnimDef
		{
			if(_anims && _anims[_cur])
				return _anims[_cur];
			return null;
		}
	}
}

final class AnimDef
{
	public var name:*;
	public var spriteSheetID:String;
	public var frameIndices:Vector.<int>;
	public var tickTimes:int;
	public var curTick:int;
	public var totalTicks:int;
	public var repeat:int;
	public var loop:Boolean;
	
	public var keyframes:Array = [];
}