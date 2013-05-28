package engine.render2D.spritesheet
{
    import engine.managers.AssetsManager;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Handles loading and retrieving data about a sprite sheet to use for rendering.
     * 
     * <p>On the subject of sprite sheet order: the divider may alter this, but in
     * general, frames are numbered left to right, top to bottom. </p>
     * 
     * <p>Be aware that Flash implements an upper limit on image size - going over
     * 2048 pixels in any dimension will lead to problems.</p>
     */ 
    public class SpriteSheet extends BaseSpriteSheet
    {
		private var _divider:ISpriteSheetDivider = null;
		private var _forcedBitmaps:Vector.<BitmapData> = null;
		private var _imageFilename:String;
		private var _image:Bitmap;
		
        /**
         * True if the image data associated with this sprite sheet has been loaded.
         */
        public override function get isLoaded():Boolean
        {
            return (imageData != null || _forcedBitmaps)
        }
        
        /**
         * The image resource to use for this sprite sheet.
         */
        public function set image(value:Bitmap):void
        {
            _image = value;
            deleteFrames();
        }
		public function get image():Bitmap	{	return _image;	}
        
        /**
         * The bitmap data of the loaded image.
         */
        public function get imageData():BitmapData{
            if (!_image)
                return null;
            
            return _image.bitmapData;
        }
		
		/**
		 * The divider to use to chop up the sprite sheet into frames. If the divider
		 * isn't set, the image will be treated as one whole frame.
		 */
		public function set divider(value:ISpriteSheetDivider):void
        {
            _divider = value;
            _divider.owningSheet = this;
            deleteFrames();
        }
        public function get divider():ISpriteSheetDivider	{ return _divider;	}
		
		/**
		 * @inhertDoc
		 */		
        protected override function getSourceFrames():Vector.<BitmapData>
        {
            // If user provided their own bitmapdatas, return those.
            if(_forcedBitmaps)
                return _forcedBitmaps;
            
            var frames:Vector.<BitmapData>;
            
            // image isn't loaded, can't do anything yet
            if (!imageData)
                return null;
            
            // no divider means treat the image as a single frame
			
			
            if (!_divider)
            {
				frames = new Vector.<BitmapData>(1, true);
                frames[0] = imageData;
            }
            else
            {
				const zero:Point = new Point(0,0);
				
				frames = new Vector.<BitmapData>(_divider.frameCount, true);
				
                for (var i:int = 0; i < _divider.frameCount; i++)
                {
                    var area:Rectangle = _divider.getFrameArea(i);										
                    frames[i] = new BitmapData(area.width, area.height, true);
                    frames[i].copyPixels(imageData, area, zero);									
                }				
            }		
			
            return frames;
        }
        
        /**
         * From an array of BitmapDatas, initialize the sprite sheet, ignoring
         * divider + filename.
         */
        public function initializeFromBitmapDataArray(bitmaps:Vector.<BitmapData>):void
        {
            _forcedBitmaps = bitmaps;
        }
	}
}
