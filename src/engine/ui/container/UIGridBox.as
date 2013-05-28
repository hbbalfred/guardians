package engine.ui.container
{
	import flash.display.Sprite;
	
	import engine.ui.comps.UIComponent;

	/**
	 * Grid Box
	 * @author Tang Bo Hao
	 */
	public class UIGridBox extends UIContainer
	{
		// GridBox properties
		protected var _grids:Vector.<UIComponent>;
		
		public function UIGridBox(id:String, display:Sprite, owner:UIComponent)
		{
			super(id, display, owner);
		}
		
		// >> Public Functions <<
		/**
		 * GridBox initialize
		 * @param ltBtnName
		 * @param rtBtnName
		 * @param gridPattern
		 * @param data
		 */
		public function initializeComp(nextBtnName:String, prevBtnName:String, gridPattern:RegExp, pageTF:String = null):void
		{
			super.initializeContainer(nextBtnName, prevBtnName, pageTF );
			
			// grids
			var child:UIComponent,
				matchArr:Array,
				tempArr:Array = new Array;
			for each( child in this._children){
				matchArr = child.name.match(gridPattern);
				if(matchArr && matchArr[1]){
					tempArr[matchArr[1]] = child;
				}
			}
			_grids = new Vector.<UIComponent>;
			for each( var item:UIComponent in tempArr){
				_grids.push(item);
			}
			// set max item per page
			_maxItemPerPage = _grids.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateData(v:*):void
		{
			if(!actived) return;
			
			super.updateData(v);
			_grids.forEach(function(child:UIComponent, index:int, ...rest):void{
				child.updateData( _data[startIndex+index] );
			});
		}

		/**
		 * @inheritDoc
		 */
		override public function linkProperty(cls:Class, propName:String=""):UIComponent
		{
			if(!actived) return this;
			
			_grids.forEach(function(child:UIComponent, ...rest):void{
				child.linkProperty(cls, propName);
			});
			return this;
		}
		
		// >> accessors <<
		public function get gridComponents():Vector.<UIComponent> {	return this._grids;	}
	}
}