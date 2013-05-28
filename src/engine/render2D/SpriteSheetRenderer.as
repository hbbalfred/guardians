package	engine.render2D	
{
    import flash.display.BitmapData;
    
    import engine.render2D.spritesheet.BaseSpriteSheet;
    import engine.render2D.spritesheet.SpriteSheetManager;
    
	/**
	 * Sprite Sheet Renderer Component
	 * @author Tang Bo Hao
	 */
	public class SpriteSheetRenderer extends BitmapRenderer
	{	
		[PBInject] public var spriteSheetMgr:SpriteSheetManager;
		
		private var _spriteDirty:Boolean = false;
        private var _spriteIndex:int = -1;
		
		private var _spriteSheetID:String;
		private var _spriteSheet:BaseSpriteSheet;
		
		/**
		 * @inheritDoc
		 */
		override protected function onAdd():void
		{
			super.onAdd();
			
			if(_spriteSheetID){
				var temp:String = _spriteSheetID;
				_spriteSheetID = "";
				spriteSheetID = temp;
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function onRemove():void
		{
			_spriteSheet = null;
			
			super.onRemove();
		}
		
		
		public function set spriteSheetID(value:String):void
		{
			if( _spriteSheetID == value) return;
			
			if(this.spriteSheetMgr)
			{
				_spriteSheet = this.spriteSheetMgr.getSpriteSheetByID(value);
				if(_spriteSheet) _spriteDirty = true;
			}
			
			_spriteSheetID = value;
		}
		public function get spriteSheetID():String	{	return _spriteSheetID;	}
		
		/**
		 * Current sprite index
		 * @param value
		 */
		public function set spriteIndex(value:int):void
		{
			if(!_spriteSheet || _spriteIndex == value) return;
			
			_spriteIndex = value;
			
			if(updateBitmapData()){
				_spriteDirty = false;
			}else{
				_spriteDirty = true;
			}
		}
		public function get spriteIndex():int	{	return _spriteIndex;	}
		
		/**
		 * Current Sprite Frame
		 * @return
		 */
        protected function getCurrentFrame():BitmapData
        {
            if (!_spriteSheet || !_spriteSheet.isLoaded)
                return null;
            
			var curFrame:BitmapData;
			curFrame = _spriteSheet.getFrame(spriteIndex);
			
			if(_spriteSheet && _spriteSheet.isLoaded && _spriteSheet.center)
			{
				origin = _spriteSheet.center.clone();					
			}
			
			return curFrame;
        }
		
		/**
		 * @inheritDoc
		 */
		override public function set imageName(value:String):void
		{
			throw new Error("Can not set imageName in SpriteSheet Renderer");
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function doFrame():void
		{
			if(_spriteDirty){
				updateBitmapData();
				_spriteDirty = false;
			}
			
			super.doFrame();
        }
		// >> Protected Function <<
		protected function updateBitmapData():Boolean{
			// Update the bitmapData.
			var targetBD:BitmapData = getCurrentFrame();
			if(bitmapData != targetBD && targetBD!=null)
			{
				bitmapData = targetBD;
				// Remove this to optimize
//				(this.displayObject as InteractivePNG).drawBitmapHitArea();
				return true;
			}else{
				return false;
			}
		}
	}
}