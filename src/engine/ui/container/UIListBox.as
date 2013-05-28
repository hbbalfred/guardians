package engine.ui.container
{
	import com.soma.ui.ElementUI;
	import com.soma.ui.layouts.VBoxUI;
	import com.soma.ui.vo.GapUI;
	import com.soma.ui.vo.PaddingUI;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import engine.ui.UICompFactory;
	import engine.ui.comps.UIComponent;
	import engine.ui.comps.UIInteractive;
	import engine.utils.MathUtils;
	
	import org.osflash.signals.Signal;

	/**
	 * This is the handler class for List Box
	 * the list box is Vertical
	 * @author Tang Bo Hao
	 */
	public class UIListBox extends UIContainer
	{
		// Constant
		public static const MIN_BUTTON_HEIGHT:Number = 20;
		private static const DEFAULT_MAXPERPAGE:int = 25;
		
		// Injection
		[PBInject] public var uiCompFactory:UICompFactory;
		
		// signal
		public const sig_scrollUpdate:Signal = new Signal;
		
		// ---- Members ----
		// List Data
		protected var _enableScroll:Boolean = false;
		
		// List Factory
		private var _displayClass:Class;
		private var _nameStart:String;
		private var _factoryFunc:Function;
		
		// panel
		private var _panelRect:Rectangle = null;
		private var _panelBox:VBoxUI = null;
		private var _panelHeight:Number = 0;
		private var _panel:UIComponent = null;

		// scroll bar
		private var _scrollInteractive:Boolean = false;
		private var _scrollButton:UIInteractive= null;
		private var _scrollArea:UIComponent = null; 
		
		public function UIListBox(id:String, display:Sprite, owner:UIComponent)
		{
			super(id, display, owner);
		}
		
		// >> Public Functions <<
		override public function destroy():void
		{
			this.sig_scrollUpdate.removeAll();
			
			// remove interactive
			scrollInteractive = false;
			
			// list data
			_data.length = 0;
			_data = null;
			
			_panelRect = null;
			_panel = null;
			
			_scrollButton = null;
			_scrollArea = null;
			
			if(_panelBox){
				_panelBox.dispose();
				_panelBox = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Init the component
		 * @param panelName
		 * @param scrollBtnName
		 * @param scrollAreaName
		 * @param optoin
		 */
		public function initializeComp(panelName:String, scrollBtnName:String = null, scrollAreaName:String = null, option:Object = null):void
		{
			option ||= {};
			super.initializeContainer(option.next, option.prev, option.page);
			
			_maxItemPerPage = DEFAULT_MAXPERPAGE;
			
			// list panel init
			_panel = this.getChildByName(panelName);
			if(_panel.children){
				_panel.children.forEach(function(child:UIComponent, ...rest):void{
					child.content.parent.removeChild(child.content);
				}, this);
			}
			// panel content
			var panelContent:DisplayObjectContainer = _panel.content as DisplayObjectContainer;
			_panelRect = panelContent.getBounds(this.content);
			_panelBox = new VBoxUI( panelContent, panelContent.width, panelContent.height );
			_panelBox.ratio = ElementUI.RATIO_IN;
			_panelBox.childrenGap = new GapUI(0, option.gap||0);
			_panelBox.childrenPadding = new PaddingUI(option.l||0, option.r||0, option.t||0, option.b||0);
			_panelBox.childrenAlign = VBoxUI.ALIGN_TOP_CENTER;
			panelContent.addChild(_panelBox);
			
			// Scroll bar
			if(scrollBtnName && scrollAreaName)
			{
				_enableScroll = true;
				
				this._scrollButton = this.getChildByName(scrollBtnName) as UIInteractive;
				this._scrollArea = this.getChildByName(scrollAreaName);
				
				refreshScrollBtn();
				updateByScrollbar();
			}
		}
		
		/**
		 * Setup the default list factory
		 * @param displayClass this should be a InteractiveObject Class
		 * @param nameStart String format should be /name(/d+)/
		 * @param factoryFunc
		 */
		public function setupListFactory( displayClass:Class, nameStart:String, factoryFunc:Function = null ):void{
			this._factoryFunc = factoryFunc;
			this._displayClass = displayClass;
			this._nameStart= nameStart;
		}
		
		// refresh list data
		/**
		 * @inheritDoc
		 */
		override public function updateData(v:*):void
		{
			if(!actived) return;
			
			super.updateData(v);
			
			if( _data.length > 0 && listItems){
				listItems.forEach(function(child:UIComponent, index:int, ...rest):void{
					child.updateData( _data[startIndex+index] );
				});
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set startIndex(index:int):void
		{	
			if(!actived) return;
			
			index = MathUtils.clamp(index, 0, _data.length);
			if(index == this._currStartIndex ) return;
			
			// Remove Old Data
			_panelHeight = 0;
			_panel.clearChildren();
			_panelBox.removeChildren();
			
			// Add New Data
			var max:int = MathUtils.clamp(index + maxItemPerPage, 0, _data.length );
			for (var i:int = index ; i < max ; i++){
				var ui:UIComponent = getUIItemByData(i);
				
				if( ui ){
					_panelBox.addChild(ui.content);
					_panelHeight += ui.content.height;
				}
			}
			
			super.startIndex = index;
			
			// Refresh Box UI
			_panelBox.refresh();
			
			if(_enableScroll){
				refreshScrollBtn();
				updateByScrollbar();
				setScrollBtnY(0);
			}
		}
		
		
		/**
		 * Add some ui to this list
		 * @param ui
		 * @return
		 */
		public function addToList(data:*):void
		{
			var ui:UIComponent = getUIItemByData( data );
			
			if( ui ){
				_panelBox.addChild(ui.content);
				_panelHeight += ui.content.height;
				if( _data.length > 0 ){
					_data.splice( lastIndex - 1 , 0, data );
				}else{
					_data = [ data ];
				}
				
				_panelBox.refresh();
				
				updateData( null );
				
				if(_enableScroll){
					refreshScrollBtn();
					updateByScrollbar();
				}else{
					_panelBox.y = 0;
				}
			}
		}
		
		/**
		 * Remove by list index
		 * @param index
		 */
		public function removeByIndex( index:int ):void{
			if( startIndex + index > lastIndex ) return;
			
			var data:* = _data.splice( startIndex + index, 1 );
			var itemui:UIComponent = _panel.children[index]
			_panel.removeChild( itemui );
			_panelBox.removeChild( itemui.content );
			_panelHeight -= itemui.content.height;
			
			var oldY:Number = _panelBox.y;
			_panelBox.refresh();
			
			if(_enableScroll){
				refreshScrollBtn();
				
				var percent:Number = MathUtils.clamp(-( oldY + itemui.content.height ) / ( _panelHeight - _panelRect.height ));
				scrollBtn.y = ( scrollArea.height - scrollBtn.height ) * percent + scrollArea.y;
				updateByScrollbar();
			}else{
				_panelBox.y = 0;
			}
		}
		
		/**
		 * Get listItems
		 * @return 
		 */
		public function get listItems():Vector.<UIComponent> { return _panel.children; }
		
		/**
		 * Refresh scroll bar to some item 
		 * @param index
		 */
		public function scrollToIndex( index:int ):void
		{
			var item:UIComponent = _panel.children[index];
			if( item ){
				var itemRect:Rectangle = item.content.getBounds(_panel.content );
				var percent:Number = ( itemRect.y - _panelBox.y ) / ( _panelHeight - _panelRect.height );
				setScrollBtnY( (scrollArea.height - scrollBtn.height) * percent + scrollArea.y );
			}else{
				setScrollBtnY(0);
			}
		}
		
		/**
		 * Refresh all the scrollbar information
		 * @param soft
		 */
		public function updateByScrollbar():void
		{	
			if(!_enableScroll) return;
			
			if(!isMoreThanOnePage){
				this.scrollInteractive = false;
				_panelBox.y = 0;
			}else{
				this.scrollInteractive = true;
				var percent:Number = (scrollBtn.y - scrollArea.y) / ( scrollArea.height - scrollBtn.height );
				
				_panelBox.y = - (_panelHeight - _panelRect.height) * percent;
			}
			
			updateItemVisible();
			sig_scrollUpdate.dispatch();
		}
		
		/**
		 * get whether the component has more than one page
		 * @return Boolean
		 */
		public function get isMoreThanOnePage():Boolean
		{
			return _panelHeight >= _panelRect.height;
		}
		
		// ========== Private =============
		/**
		 * Get the ui item
		 * @param data
		 * @return 
		 */
		private function getUIItemByData( data:* ):UIComponent{
			var retUI:UIComponent;
			if(data is UIComponent && _panel.getChildByName( UIComponent(data).name ) != null){
				retUI = UIComponent(data);
			}else if( data is String ){
				retUI = _panel.getChildByName(String(data));
			}else if( data is Number || data is int){
				retUI = this.generateListItem( data );
			}
			return retUI;
		}
		/**
		 * Generate a list item
		 * @return
		 */
		private function generateListItem(index:int):UIComponent{
			var newItem:UIComponent = null;
			if(_displayClass){
				var newDisplay:InteractiveObject = new _displayClass;
				if(newDisplay){
					newDisplay.name = _nameStart.replace(/(\d+)/, index); 
					newItem = uiCompFactory.createUI(newDisplay, _panel);
					
					if( newItem && _factoryFunc != null) 
						_factoryFunc(newItem);
				}
			}
			
			return newItem;
		}
		
		private function updateItemVisible():void
		{
			if( _panel.children == null) return;
			
			_panel.children.forEach(function(item:UIComponent, ...rest):void{
				var itemRect:Rectangle = item.content.getBounds(_panel.content );
				if( itemRect.y + itemRect.height < 0
				 || itemRect.y > _panelRect.height ){
					item.visible = false;
				}else{
					item.visible = true;
				}
			});
			
		}
		
		/**
		 * Resize ScrollBtn
		 */
		private function refreshScrollBtn():void{
			if(!isMoreThanOnePage){
				scrollBtn.height = scrollArea.height;
			}else{
				scrollBtn.height = MathUtils.clamp(_panelRect.height / _panelHeight * scrollArea.height, MIN_BUTTON_HEIGHT, scrollArea.height);
			}
		}
		
		/**
		 * Set scroll enable or not
		 * @param value
		 * 
		 */
		private function set scrollInteractive(value:Boolean):void
		{
			if(value == _scrollInteractive) return; 
			
			if(value){
				_scrollButton.enabled = true;
				_scrollButton.pressingEnabled = true;
				_scrollButton.onMouseDown.add(on_MouseDown);
				_scrollButton.onMousePressing.add(on_Press);
				
				this.content.addEventListener(MouseEvent.MOUSE_WHEEL, wheeling);
			}else{
				_scrollButton.onMouseDown.remove(on_MouseDown);
				_scrollButton.onMousePressing.remove(on_Press);
				_scrollButton.pressingEnabled = false;
				_scrollButton.enabled = false;
				
				this.content.removeEventListener(MouseEvent.MOUSE_WHEEL, wheeling);
			}
			
			_scrollInteractive = value;
		}
		
		// Mouse Events
		private var _startOffsetY:Number;
		private function on_MouseDown(mouseX:Number, mouseY:Number):void
		{
			var mousePos:Point = scrollBtn.parent.globalToLocal(new Point(mouseX, mouseY)); 
			_startOffsetY = mousePos.y - scrollBtn.y;
		}
		
		private function on_Press(mouseX:Number, mouseY:Number):void
		{
			var mousePos:Point = scrollBtn.parent.globalToLocal(new Point(mouseX, mouseY));
			setScrollBtnY( mousePos.y - _startOffsetY );
		}
		
		//  Wheel up and down 
		private function wheeling(e:MouseEvent):void
		{
			setScrollBtnY( scrollBtn.y - e.delta );
		}
		
		private function setScrollBtnY( newY:Number ):void
		{
			newY = MathUtils.clamp(newY , scrollArea.y, scrollArea.y + scrollArea.height - scrollBtn.height);
			
			if(newY != scrollBtn.y){
				scrollBtn.y = newY;
				updateByScrollbar();
			}
		}

		// ---- Accessors ----
		private function get scrollBtn():InteractiveObject {	return this._scrollButton.content; }
		private function get scrollArea():DisplayObjectContainer {	return this._scrollArea.content as DisplayObjectContainer; }
	}	
}