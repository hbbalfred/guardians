package engine.render2D.spritesheet
{
    import engine.utils.MovieClipUtils;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /**
     * A class that is similar to the SpriteSheetComponent except the frames
     * are loaded by rasterizing frames from a MovieClip rather than splitting
     * a single image.
	 * 
	 * Note the rasterize just supports simple animation.
     */
    public class SWFSpriteSheet extends BaseSpriteSheet
    {
        /**
         * When cached is set to true (the default) the rasterized frames
         * are re-used by all instances of the SWFSpriteSheetComponent
         * with the same values for swf, smoothing, and clipName.
         */
        public var cached:Boolean = true;

        /**
         * The bounds of the source MovieClip.
         * This can be used for clips that are expected to be rendered based on their bounds.
         */
        public function bounds( index:int ):Rectangle
        {
			var b:Rectangle = _frameBounds[ index ];
            return new Rectangle(b.x, b.y, b.width * _scale.x, b.height * _scale.y);
        }

        /**
         * Whether or not the bitmaps that are drawn should be smoothed. Default is True.
         */
        public function get smoothing():Boolean { return _smoothing; }
        public function set smoothing(value:Boolean):void 
        {
            _smoothing = value;
        }

        /**
         * X/Y scaling for the SWF as it renders to bitmap.  
         * 
         * Value of (1, 1) mean no scaling (default).  
         * 
         * (0.5, 0.5) would be half the normal size, and (2, 2) would be double.
         */
        public function get scale():Point{ return _scale.clone(); }
        public function set scale(value:Point):void
        {
            _scale = value.clone();
        }
		
		/**
		 * create a sprite sheet 
		 * @param clip, movieclip
		 * @param className, movieclip type 
		 * @param domain, movieclip application domain id
		 * 
		 */
		public function create( clip:MovieClip, className:String, domain:String):void
		{
			_clip = clip;
			_className = className;
			_domain = domain;
			
			clip.stop();
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function getFrame(index:int):BitmapData
		{
			var b:Rectangle = _frameBounds[ index ];
			center = new Point( -b.x, -b.y );
			return super.getFrame( index );
		}
        
		/**
		 * @inheritDoc 
		 */
        override public function get isLoaded() : Boolean
        {
            if (!_clip) 
                return false;

            if (!_frames) 
                rasterize();

            return _frames != null;
        }
		
		override public function destroy():void
		{
			super.destroy();
			
			for(var i:* in _frameCache)
				delete _frameCache[i];
			_frameCache = null;
		}
		

        /**
         * Rasterizes the associated MovieClip and returns a list of frames.
         */
        override protected function getSourceFrames():Vector.<BitmapData>
        {
            if (!_clip )
                return null;

            if (!_frames)
                rasterize();

            return _frames;
        }

        /**
         * Reads the frames from the cache. Returns a null reference if they are not cached.
         */
        protected function getCachedFrames():CachedFramesData
        {
            if (!cached) 
                return null;

            return _frameCache[getFramesCacheKey()] as CachedFramesData;
        }

        /**
         * Caches the frames based on the current values.
         */
        protected function setCachedFrames(frames:CachedFramesData):void 
        {
            if (!cached) 
                return;

            _frameCache[getFramesCacheKey()] = frames;
        }

        protected function getFramesCacheKey():String
        {
            return _domain + ":" + (_className ? _className : "") + (_smoothing ? ":1" : ":0");
        }

        /**
         * Rasterizes the clip into an Array of BitmapData objects.
         * This array can then be used just like a sprite sheet.
         */
        protected function rasterize():void
        {
            if (!_clip) return;

            var frames:CachedFramesData = getCachedFrames();
            if (frames)
            {
                _frames = frames.frames;
				_frameBounds = frames.frameBounds;
                _clip = frames.clip;
                return;
            }
			
			
			onRasterize(_clip);
            setCachedFrames(new CachedFramesData(_frames, _frameBounds, _clip));
        }

        /**
         * Performs the actual rasterizing. Override this to perform custom rasterizing of a clip.
         */
        protected function onRasterize(mc:MovieClip):void
        {
            var maxFrames:int = MovieClipUtils.maxFrames( mc, mc.totalFrames );
            var rasterized:Vector.<BitmapData> = new Vector.<BitmapData>( maxFrames, true );
			var bounds:Vector.<Rectangle> = new Vector.<Rectangle>( maxFrames, true );

//            if (maxFrames > 0)
//                rasterized[0] = rasterizeFrame(mc, 1);
			for(var i:int = 0; i < rasterized.length; ++i)
			{
				var result:Object = rasterizeFrame(mc, i+1); 
				rasterized[i] = result.bitmapData;
				bounds[i] = result.bounds;
			}
			

            _frames = rasterized;
			_frameBounds = bounds;
        }

        protected function rasterizeFrame(mc:MovieClip, frameIndex:int):Object
        {
            if (mc.totalFrames >= frameIndex)
                mc.gotoAndStop(frameIndex);
			
			MovieClipUtils.gotoAndStopChildren( mc, frameIndex );
			
            var bd:BitmapData = getBitmapDataByDisplay(mc);
			var bounds:Rectangle = mc.getBounds(mc);
			
            return {bitmapData:bd, bounds:bounds};
        }

        /**
         * Draws the DisplayObject to a BitmapData using the bounds of the object.
         */
        protected function getBitmapDataByDisplay(display:DisplayObject):BitmapData 
        {
            var bounds:Rectangle = display.getBounds(display);
			if(bounds.width == 0)
				bounds.width = 1;
			if(bounds.height == 0)
				bounds.height = 1;
			
			var bd:BitmapData = new BitmapData(
				Math.min( 2880, bounds.width ),
				Math.min( 2880, bounds.height ),
				true, 0);
			
			var mat:Matrix = new Matrix( 1,0,0,1, -bounds.x, -bounds.y );
            bd.draw(display, mat, null, null, null, _smoothing);
			
			if( _scale.x != 1 || _scale.y != 1 )
			{
				mat.identity();
				mat.scale( _scale.x, _scale.y );
				if(_scale.x < 0) mat.translate( -bd.width * _scale.x, 0 );
				if(_scale.y < 0) mat.translate( 0, -bd.height * _scale.y );
				
				var tmp:BitmapData = bd;
				
				bd = new BitmapData(
					Math.min( 2880, bounds.width * Math.abs(_scale.x) ),
					Math.min( 2880, bounds.height * Math.abs(_scale.y) ),
					true, 0);
				bd.draw( tmp, mat );
				tmp.dispose();
			}

            return bd;
        }

        private var _frameCache:Dictionary = new Dictionary();

        private var _smoothing:Boolean = true;
        private var _scale:Point = new Point(1, 1);
        private var _frames:Vector.<BitmapData>;
		private var _frameBounds:Vector.<Rectangle>;
        private var _className:String;
        private var _clip:MovieClip;
		private var _domain:String;
    }
}
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.geom.Rectangle;

final class CachedFramesData
{
    public function CachedFramesData(frames:Vector.<BitmapData>, frameBounds:Vector.<Rectangle>, clip:MovieClip)
    {
        this.frames = frames;
		this.frameBounds = frameBounds;
        this.clip = clip;
    }
    public var frames:Vector.<BitmapData>;
    public var frameBounds:Vector.<Rectangle>;
    public var clip:MovieClip;
}
