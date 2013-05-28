package engine.render2D
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import engine.managers.AssetsManager;
	import engine.utils.InteractivePNG;

	/**
	 * Bitmap Render
	 * @author Tang Bo Hao
	 */
	public class BitmapRenderer extends DisplayObjectRenderer
	{
		// >> Injection <<
		[PBInject] public var assetsMgr:AssetsManager;
		
		protected var _imageName:String = "";
		protected var _bitmap:Bitmap = new Bitmap();
		protected var _smoothing:Boolean = false;
		protected var _container:Sprite = new Sprite();
		
		/**
		 * @inheritDoc 
		 */
		protected override function onAdd():void
		{	
			super.onAdd();
			
			smoothing = false;
			
			if(_imageName){
				var temp:String = _imageName;
				_imageName = "";
				imageName = temp;
			}
		}
		
		/**
		 * a image file
		 */
		public function set imageName(value:String):void
		{
			if(_imageName == value) return;
			
			if(assetsMgr) {
				var data:Bitmap = assetsMgr.getItemSync( value );
				bitmapData = Bitmap(data).bitmapData;
			}
			_imageName = value;
		}
		public function get imageName():String	{	return _imageName;	}
		
		
		/**
		 * @see Bitmap.smoothing 
		 */
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			_bitmap.smoothing = value;
		}
		public function get smoothing():Boolean	{	return _smoothing; 	}
		
		/**
		 * @see Bitmap.bitmapData 
		 * @return 
		 */
		public function get bitmapData():BitmapData
		{
			return _bitmap.bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			if (!value || value === _bitmap.bitmapData)
				return;
			
			_bitmap.bitmapData = value;
			_bitmap.x = -origin.x;
			_bitmap.y = -origin.y;
			
			if (displayObject==null)
			{
				_displayObject = new InteractivePNG();
				(_displayObject as Sprite).addChild(_container);
				_container.addChild(_bitmap);
				
				if(name && owner && owner.name)
					_displayObject.name = owner.name + "." + name;
				
				if(renderMgr){
					// Add new scene.
					addToScene();
				}
			}
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
		}
		
		/**
		 * Disable displayObject Setter
		 * @param value
		 */
		override public function set displayObject(value:DisplayObject):void
		{
			throw new Error("Cannot set displayObject in BitmapRenderer; it is always a Sprite containing a Bitmap.");
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function get body():DisplayObject
		{
			return _container;
		}
	}
}