package engine.ui.comps
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import engine.managers.FontManager;

	/**
	 * TextField Wrapper Class for displaying textfield 
	 * @author Tang Bo Hao
	 */
	public class UITextField extends UIComponent
	{
		[PBInject] public var fontMgr:FontManager;
		
		// constant
		protected static const FIXWIDTH_RegExp:RegExp = /.+\$\$w\$/g;
		protected static const FIXHEIGHT_RegExp:RegExp = /.+\$\$h\$/g;
		
		private var _isHtml:Boolean = false;
		private var _fixHeight:Boolean = false;
		private var _fixWidth:Boolean = false;
		private var _baseAdjustSize:int = 0;
		
		/**
		 * Constructor
		 * @param tf textfield instance
		 * @param options
		 */
		public function UITextField(id:String, tf:TextField, owner:UIComponent)
		{
			super(id, tf, owner);
			
			// default selectable is false
			this.textField.mouseEnabled = false;
			this.textField.mouseWheelEnabled = false;
			this.textField.selectable = false;
			this.textField.embedFonts = true;
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.autoSize = TextFieldAutoSize.NONE;
			
			var name:String = tf.name;
			this.fixHeight = name.match( FIXHEIGHT_RegExp ).length > 0;	
			this.fixWidth = name.match( FIXWIDTH_RegExp ).length > 0;
		}
		
		/**
		 * update the textfiled
		 * @param value
		 */
		override public function updateData(data:*):void
		{
			if( !_linkedProperty && _mapFunc == null )
				return; 
			
			var v:* = this.getLinkedProperty(data);
			if( v == 0 || v is int) v = v + "";
			else if( v is Number ) v = Number(v).toFixed(1);
			else if( !(v is String) ){
				v = "";
			}
			
			this.value = v != null ? v : "NULL"; 
		}
		
		// ====== Getter and Setter =======
		public function get textField():TextField{
			return this._display as TextField;
		}
		
		public function set isHTML( v:Boolean ):void{
			this._isHtml = v;	
		}
		public function get isHTML():Boolean{
			return this._isHtml;
		}
		
		public function set isEmbedFont( v:Boolean ):void
		{
			this.textField.embedFonts = v;
		}
		
		public function set fixHeight( value:Boolean ):void{
			_fixHeight = value;
		}
		public function set fixWidth( value:Boolean ):void{
			_fixWidth = value;
		}
		
		public function set baseAdjustSize( value:int ):void{
			_baseAdjustSize = value;
		}
		
		override protected function updateValue():void
		{
			fontMgr.applyFont( textField );
			var textValue:String = this.value || "";
			if( !_isHtml ){
				this.textField.text = textValue;
			}else{
				this.textField.htmlText = textValue;
			}
			
			if( _fixHeight || _fixWidth ){
				var fixedValue:Number = _fixHeight ? textField.height : ( _fixWidth ? textField.width : 0 ); 
				var size:int = _baseAdjustSize;
				var fontName:String = textField.getTextFormat().font;
				do{
					textField.htmlText = '<font face="'+fontName+'" size="'+ (size>=0 ? '+': '') + (size--) +'">' + textValue + '</font>';
				}while( currValue > fixedValue );
			}
		}
		
		private function get currValue():Number {
			if( _fixHeight ){
				return this.textField.textHeight + 1;
			}else if( _fixWidth ){
				return this.textField.textWidth + 4; // hack for letter spacing
			}else
				return -1;
		}
	}
}