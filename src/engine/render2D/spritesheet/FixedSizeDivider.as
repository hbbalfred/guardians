package engine.render2D.spritesheet
{
    import engine.framework.debug.Logger;
    
    import flash.geom.Rectangle;
    
    /**
     * Divide a sprite sheet into fixed-size cells.
     */
    public class FixedSizeDivider implements ISpriteSheetDivider
    {
        /**
         * The width of each frame.
         */
        public var width:int = 32;
        
        /**
         * The height of each frame.
         */
        public var height:int = 32;
        
        /**
         * The spacing between frames
         */	
        public var spacing:int = 0;
		
		/**
		 * The margin of sprite sheet
		 */
		public var margin:int = 0;
        
        /**
         * @inheritDoc
         */
        public function set owningSheet(value:SpriteSheet):void
        {
            if(_owningSheet)
                Logger.warn(this, "set OwningSheet", "Already assigned to a sheet, reassigning may result in unexpected behavior.");
            _owningSheet = value;
        }
        
        /**
         * @inheritDoc
         */
        public function get frameCount():int
        {
            if (!_owningSheet)
                throw new Error("OwningSheet must be set before calling this!");
            
            return Math.floor(_owningSheet.imageData.width / width) * Math.floor(_owningSheet.imageData.height / height);
        }
        
        /**
         * @inheritDoc
         */
        public function getFrameArea(index:int):Rectangle
        {
            if (!_owningSheet)
                throw new Error("OwningSheet must be set before calling this!");
            
            var x:int = index % Math.floor(_owningSheet.imageData.width / width);
            var y:int = Math.floor(index / Math.floor(_owningSheet.imageData.width / width));
            
            return new Rectangle(x * (width + spacing) + margin, y * (height + spacing) + margin, width, height);
        }
        
        /**
         * @inheritDoc
         */
        public function clone():ISpriteSheetDivider
        {
            var c:FixedSizeDivider = new FixedSizeDivider();
            c.width = width;
            c.height = height;
            return c;
        }
        
        private var _owningSheet:SpriteSheet;
    }
}