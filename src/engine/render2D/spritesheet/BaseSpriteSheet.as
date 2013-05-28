package engine.render2D.spritesheet
{   
    import flash.display.BitmapData;
    import flash.geom.Point;
    
    /**
     * An abstract class to allow access to a set of sprites.
     * This needs to be inherited to be of any use.
     * @see SpriteSheetComponent
     * @see SWFSpriteSheetComponent
     */
    public class BaseSpriteSheet
    {
		// >> Members <<
		protected var frames:Vector.<BitmapData>;
		
		private var _firstGID:int = 0;
		
		// Center
		private var _center:Point = new Point(0, 0);
		private var _defaultCenter:Boolean = true;
		
		/**
		 * @inheritDoc 
		 */
		public function destroy():void
		{
			deleteFrames();
		}
		
		public function get totalFrames():int
		{
			return getSourceFrames().length;
		}
			
        /**
         * Subclasses must override this method and return an
         * array of BitmapData objects.
         */
        protected function getSourceFrames():Vector.<BitmapData>
        {
            throw new Error("Not Implemented");
        }
        
        /**
         * Deletes the frames so this class can be re-used with a new set of frames.
         */
        protected function deleteFrames():void
        {
			if(!frames) return;
			
			for( var i:int = frames.length - 1; i > -1; --i)
			{
				frames[i].dispose();
			}
            frames = null;
        }
        
        /**
         * True if the frames associated with this sprite container have been loaded.
         */
        public function get isLoaded():Boolean
        {
            return frames != null;
        }
        
        /**
         * Specifies an offset so the sprite is centered correctly. If it is not
         * set, the sprite is centered.
         */
        public function get center():Point
        {
            if(!_center)
                return new Point();
            
            return _center;
        }
        public function set center(v:Point):void
        {
            _center = v;
            _defaultCenter = false;
        }

		/**
		 * Indicates that the spriteSheet has a centered alignment.
		 */
		public function get centered():Boolean
		{
			return _defaultCenter;
		}
		
		/**
		 * If GID is set, getFrame will minus this first
		 */
		public function get firstGID():int
		{
			return _firstGID;
		}
		
		public function set firstGID(value:int):void
		{
			_firstGID = value;
		}
		
        /**
         * Gets the bitmap data for a frame at the specified index.
         * 
         * @param index The index of the frame to retrieve.
         * @param direction The direction of the frame to retrieve in degrees. This
         *                  can be ignored if there is only 1 direction per frame.
         * 
         * @return The bitmap data for the specified frame, or null if it doesn't exist.
         */
        public function getFrame(index:int):BitmapData
        {
            if(!isLoaded)
                return null;
            
			if (frames == null){
				buildFrames();
			}
			
			if ((index < firstGID) || (index >= firstGID + frames.length))
				return null;
			
			return frames[index - firstGID]; 
        }
        
        protected function buildFrames():void
        {
            frames = getSourceFrames();
            
            // not loaded, can't do anything yet
            if (frames == null || frames.length == 0)
                throw new Error("No frames loaded");
			
			if (_defaultCenter)
				_center = new Point( frames[0].width * 0.5, frames[0].height * 0.5);
        }

    }
}