/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package engine.render2D.display
{
    import engine.render2D.DisplayObjectRenderer;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    /**
     * Layer within a DisplayObjectScene which manages a list of 
     * DisplayObjectRenderers. The layer is responsible for keeping
     * itself sorted. This is also a good site for custom render
     * effects, parallaxing, etc.
     */
    public class DisplayObjectSceneLayer extends Sprite
    {
        /**
         * Array.sort() compatible function used to determine draw order. 
         */
        public var drawOrderFunction:Function;
        
        protected var _rendererList:Vector.<DisplayObjectRenderer>;
        /**
         * Set to true when we need to resort the layer. 
         */
        private var _needSort:Boolean = false;
        
        /**
         * Default sort function, which orders by zindex.
         */
        static public function defaultSortFunction(a:DisplayObjectRenderer, b:DisplayObjectRenderer):Number
        {
            return a.zIndex - b.zIndex;
        }
        
        public function DisplayObjectSceneLayer()
        {
			_rendererList = new Vector.<DisplayObjectRenderer>;
			
            drawOrderFunction = defaultSortFunction;
			buttonMode = false;
			tabChildren = false;
			tabEnabled = false;
        }
		
		/**
		 * Indicates this layer is dirty and needs to resort.
		 */
		public function markDirty():void
		{
			this._needSort = true;
		}
		
		/**
		 * sort and update z-index of renderer Object
		 */
        public function onRender():void
        {
            if(_needSort)
            {
                updateOrder();
				this._needSort = false;
            }
        }
        
		/**
		 * 
		 * @param dor
		 */
        public function add(dor:DisplayObjectRenderer):void
        {
            var idx:int = rendererList.indexOf(dor);
            if(idx != -1)
                throw new Error("Already added!");
            
            rendererList.push(dor);
            addChild(dor.displayObject);
			markDirty();
        }
        
		/**
		 * 
		 * @param dor
		 */
        public function remove(dor:DisplayObjectRenderer):void
        {
            var idx:int = rendererList.indexOf(dor);
            if(idx == -1)
                return;
            rendererList.splice(idx, 1);
            removeChild(dor.displayObject);
        }
		
		/**
		 * All the renderers in this layer. 
		 */
		public function get rendererList():Vector.<DisplayObjectRenderer>
		{
			return _rendererList;
		}
		
		// >> Protected Functions <<   
		/**
		 * Set Layer to dirty and need sort
		 */     
		protected function updateOrder():void
		{
			// Get our renderers in order.
			// TODO: A bubble sort might be more efficient in cases where
			// things don't change order much.
			rendererList.sort(drawOrderFunction);
			
			// Apply the order.
			var updated:int = 0;
			for(var i:int=0; i<rendererList.length; i++)
			{
				var d:DisplayObject = rendererList[i].displayObject;
				if(getChildAt(i) == d)
					continue;
				
				updated++;
				setChildIndex(d, i);
			}
			
			// This is useful if you suspect you're changing order too much.
			//trace("Reordered " + updated + " items.");
		}

    }
}