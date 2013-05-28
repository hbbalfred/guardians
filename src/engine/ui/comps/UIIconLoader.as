package engine.ui.comps
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import engine.framework.debug.Logger;
	import engine.framework.util.TypeUtility;
	import engine.managers.AssetsManager;
	import engine.utils.DisplayObjectUtils;
	import engine.utils.StringUtils;

	/**
	 * Image Icon Loader Component
	 * @author Tang Bo Hao
	 */
	public class UIIconLoader extends UIComponent
	{
		[PBInject] public var assetsMgr:AssetsManager;
		
		private const ICONPOS_CLASSNAME:String = "iconpos";
		
		protected var _iconPoint:Sprite;
		protected var _currentImgName:String;
		private var _assetsKey:String;
		
		// >> Public Size Setting <<
		public var maxWidth:Number = 50;
		public var maxHeight:Number = 50;
		
		private var _autoAdjust:Boolean = true;
		
		/**
		 * @inheritDoc
		 */
		public function UIIconLoader(id:String, display:Sprite, owner:UIComponent)
		{
			super(id, display, owner);
			maxWidth = display.width - 2;
			maxHeight = display.height - 2;
			
			// to look for the icon point
			_iconPoint = this.lookforIconPoint(display);
			if(!_iconPoint){
				Logger.print(this, "No Icon Point Class Exists! ");
				_iconPoint = display;
			}
		}
		
		// >> Public Functions <<
		override public function destroy():void
		{
			this.cleanIcon();
			
			this._iconPoint = null;
			super.destroy();
		}
		public function set autoAdjust( value:Boolean ):void { 	this._autoAdjust = value; }
		public function get autoAdjust():Boolean {	return this._autoAdjust; }
		
		/**
		 * To update icon data
		 * @param data is the object
		 */
		override public function updateData(data:*):void 
		{	
			if( this._linkedProperty != null || this._mapFunc != null){
				var v:String = this.getLinkedProperty(data) as String;
				if(!v ){
					this.cleanIcon();
					this.value = null;
					return;
				}
				
				this.value = v;
			}
		}
		
		override protected function updateValue():void
		{
			var img_url:String = this.value;
			if(!img_url || img_url == this._currentImgName) return;
			
			this.cleanIcon();
			
			var first:Boolean, loadOptions:Object;
			var isCrossDomain:Boolean = Boolean(StringUtils.isURL(img_url) && img_url.indexOf(assetsMgr.rootPath) < 0);
			if( isCrossDomain || !assetsMgr.hasItem(img_url) ){
				first = true;
				_assetsKey = isCrossDomain ? StringUtils.generateGUID() : img_url;
				loadOptions = { url: img_url, nocontext: isCrossDomain, type: "image"};
			}else{
				first = false;
				_assetsKey = img_url;
				loadOptions = {type: "image"};
			}
			
			assetsMgr.getItem(_assetsKey, loadOptions, function(err:Error, icon:DisplayObject):void{
				if(err) {
					// Nothing and return
					return;
				}
				if( !this._display || !this._iconPoint ) return;

				if( isCrossDomain && assetsMgr.getItemSync( _assetsKey ) != icon ){
					return;
				}
				
				if(first && isCrossDomain){
					this.setLinkedProperty(_assetsKey);
					icon.alpha = 0.5;
					tweenMgr.add(icon, { alpha: 1 }, { time: UIComponent.DEFAULT_TWEENTIME } );
				}
				
				// Adjust size
				if(_autoAdjust)	DisplayObjectUtils.adjustSize( icon, maxWidth, maxHeight );
				this._iconPoint.addChild(icon);
			}, this);
			this._currentImgName = _assetsKey;
		}
		
		
		// >> Private Functions <<
		/**
		 * Clean current icon
		 */
		protected function cleanIcon():void
		{
			if(_iconPoint && _iconPoint.numChildren > 0){
				DisplayObjectUtils.removeAllChildren(_iconPoint);
			}
			this._currentImgName = null;
		}
		
		/**
		 * To look for the icon position point
		 * @api private
		 */
		private function lookforIconPoint(display:DisplayObjectContainer):Sprite
		{
			var ret:Sprite = null;
			
			var displays:Vector.<DisplayObject> = new Vector.<DisplayObject>(),
				currentDO:DisplayObject;
			displays.push(display);
			while(displays.length > 0){
				currentDO = displays.pop();
				if(TypeUtility.getObjectClassName(currentDO) == ICONPOS_CLASSNAME){
					ret = currentDO as Sprite;
					break;
				}else if(currentDO is DisplayObjectContainer){
					var childlen:int = DisplayObjectContainer(currentDO).numChildren, i:int = 0;
						
					while( i < childlen ) displays.push(DisplayObjectContainer(currentDO).getChildAt(i++));
				}
			}
			
			return ret;
		}

		/**
		 * The icon position
		 * @return
		 */
		public function get iconPoint():Sprite { return _iconPoint;	}		
	}
}