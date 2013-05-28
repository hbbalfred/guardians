package engine.ui.container
{
	import flash.display.Sprite;
	
	import engine.ui.comps.UIComponent;
	import engine.ui.comps.UIInteractive;
	import engine.ui.comps.UITextField;
	import engine.utils.MathUtils;
	
	import org.osflash.signals.Signal;

	/**
	 * Base Class of UIContainers
	 * @author Tang Bo Hao
	 */
	public class UIContainer extends UIComponent
	{
		private var _actived:Boolean;

		// GridBox properties
		protected var _nextBtn:UIInteractive;
		protected var _prevBtn:UIInteractive;
		protected var _pageTF:UITextField;
		protected var _data:Array;
		
		// Controll variables
		protected var _maxItemPerPage:int = 50;
		protected var _currStartIndex:int = -1;
		
		public const sig_reset:Signal = new Signal;
		
		public function UIContainer(id:String, display:Sprite, owner:UIComponent)
		{
			super(id, display, owner);
			
			_data = new Array;
			_actived = false;
		}
		
		// >> Public Functions <<
		override public function destroy():void
		{
			this.sig_reset.removeAll();
			
			_nextBtn = null;
			_prevBtn = null;
			_data = null;
			_actived = false;
			
			super.destroy();
		}
		
		/**
		 * Container initialize 
		 * @param nextBtnName
		 * @param prevBtnName
		 * @param pageTF
		 */
		protected function initializeContainer(nextBtnName:String, prevBtnName:String, pageTF:String = null):void
		{
			if(_actived) return;
			// btns
			if(nextBtnName != null && prevBtnName != null) {
				_nextBtn = this.getChildByName(nextBtnName) as UIInteractive;
				_nextBtn.grayOnDisable = false;
				_nextBtn.enableClick( onNextClick, false );
				_prevBtn = this.getChildByName(prevBtnName) as UIInteractive;
				_prevBtn.grayOnDisable = false;
				_prevBtn.enableClick( onPrevClick, false );
			}
			
			// TF
			if(pageTF){
				_pageTF = this.getChildByName( pageTF ) as UITextField;
			}
			
			_actived = true;
		}
		
		/**
		 * Reset data in the container
		 * @param data
		 */
		public function resetData(data:Array):void
		{
			if(!_actived || !data ) return;
			
			_currStartIndex = -1;
			_data = data.slice();
			startIndex = 0;
		}
		
		/**
		 * Get data from index
		 * @param index
		 * @return
		 */
		public function getData(index:int):*
		{
			return _data[_currStartIndex + index];
		}
		
		/**
		 * Get Current Data Array
		 * @return
		 */
		public function get currentDataArray():Array{
			var ret:Array = _data.slice( _currStartIndex, lastIndex ); 
			return ret;
		}
		
		/**
		 * All Data Array
		 * @return
		 */
		public function get dataArray():Array{
			return _data;
		}
		
		/**
		 * Get index from data
		 * @param data
		 * @return
		 */
		public function getIndex( data:* ):int
		{
			var index:int = _data.indexOf( data ) - _currStartIndex;
			return index < 0 ? -1 : index;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateData(v:*):void
		{
			if(!_actived) return;
			
			if(this._prevBtn && this._nextBtn) {
				// set buttons enabled
				this._nextBtn.enabled = !(startIndex + _maxItemPerPage >= _data.length);
				this._prevBtn.enabled = (startIndex - _maxItemPerPage >= 0);
			}
			
			if( _pageTF ) {
				_pageTF.value = currentPage + "/" + this.totalPage;
			}
		}
		
		// >> accessors <<
		public function get actived():Boolean { return _actived; }
		
		public function get maxItemPerPage():int { return _maxItemPerPage; }
		public function set maxItemPerPage(value:int):void { _maxItemPerPage = value; }
		
		/**
		 * set the start index of the grid box
		 * @param index
		 */
		public function set startIndex(index:int):void
		{
			if(!_actived) return;
			
			index = MathUtils.clamp(index, 0, _data.length);
			if(index == this._currStartIndex ) return;
			
			this._currStartIndex = index;
			
			// update data
			updateData(null);
			
			this.sig_reset.dispatch();
		}
		public function get startIndex():int {	return this._currStartIndex; }
		public function get lastIndex():int { return MathUtils.clamp(_currStartIndex + maxItemPerPage, 0, _data.length ); }
		
		public function get currentPage():int { return int(startIndex / _maxItemPerPage ) + 1 ; }
		public function get totalPage():int { return Math.max( 1, int( (_data.length -1 ) / _maxItemPerPage + 1) ); }
		
		// >> Protected Functions <<
		protected function onPrevClick():void{
			startIndex = startIndex - maxItemPerPage;
		}
		
		protected function onNextClick():void{
			if( startIndex + _maxItemPerPage >= _data.length ){
				startIndex = startIndex;
			}else{
				startIndex = startIndex + _maxItemPerPage;
			}
		}
	}
}