package engine.managers
{
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import engine.framework.core.IPBManager;
	
	/**
	 * Manger Font
	 * @author Tang Bo Hao
	 */
	public class FontManager implements IPBManager
	{
		[PBInject] public var assetsMgr:AssetsManager;
		
		private var _fontFormatLib:Object;
		
		public function initialize():void
		{
			_fontFormatLib = {};
		}
		
		public function destroy():void
		{
			_fontFormatLib = null;
		}
		
		/**
		 * register sometype of font as a font class
		 * @param name
		 * @param cls
		 * @param thickness hack for different FontType
		 * @return
		 */
		public function registerFont( fontName:String, fontClass:Class, defaultThickness:int = 0 ):void{
			if(fontClass){
				var fonts:Array = Font.enumerateFonts();
				for each( var font:Font in fonts){
					if ( font is fontClass ){
						_fontFormatLib[ fontName ] = { font:font, thickness: defaultThickness };
					}
				}
			}
		}
		
		public function applyFont( tf:TextField ):void
		{
			var tfInfo:Object = _fontFormatLib[ tf.defaultTextFormat.font ];
			if( !tfInfo ) return;
			
			var defaultTF:TextFormat = tf.getTextFormat();
			var tfType:Font = tfInfo.font;
			if( defaultTF.font != tfType.fontName ){
				defaultTF.font = tfType.fontName;
				tf.defaultTextFormat = defaultTF;
				tf.thickness = tfInfo.thickness;
			}
		}
	}
}