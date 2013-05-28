package engine.managers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import engine.framework.core.IPBManager;
	import engine.framework.time.IAnimated;
	import engine.framework.time.TimeManager;
	import engine.render2D.DisplayObjectRenderer;
	import engine.render2D.display.DisplayObjectSceneLayer;
	import engine.utils.DisplayObjectUtils;
	
	/**
	 * PBE Game Scene Manager, to handle DisplayObjectRender
	 * @author Tang Bo Hao
	 */
	public class RendererManager implements IPBManager, IAnimated
	{
		// >> Constant <<
		protected static const ONFRAME_PRIORITY:int = -10;
		
		// >> Injection <<
		[PBInject] public var timeMgr:TimeManager;
		
		// Protected Member
		protected var _gameStage:DisplayObjectContainer;
		protected var _stageExists:Boolean = false;
		protected var _renderers:Dictionary;
		protected var _layers:Array;
		
		/**
		 * @inheritDoc
		 */
		public function initialize():void
		{
			_renderers = new Dictionary(true);
			_layers = new Array;
			_stageExists = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function destroy():void
		{
			_layers = null;
			_renderers = null;
		}
		
		// ==== !====== Accessors ==========
		/**
		 * Accessor of Level Stage
		 * @param doc
		 */
		public function get gameStage():DisplayObjectContainer { return this._gameStage ; }
		public function get gameStageOffset():Point {	return new Point(this._gameStage.x, this._gameStage.y);	}
		
		// ==== !==== Public Function ======
		/**
		 * 
		 * @param doc
		 * 
		 */
		public function setupStage( doc:DisplayObjectContainer ):void
		{
			if(this._stageExists) return;
			
			if(doc != null) 
			{
				// Set stage
				this._gameStage = doc;
				this._stageExists = true;
				
				// Add layers
				for(var i:int=0; i<_layers.length; i++)
				{
					if (_layers[i])
						_gameStage.addChild(_layers[i]);
				}
				
				// set add to timeManager
				timeMgr.addAnimatedObject(this, ONFRAME_PRIORITY);
			}
		}
		public function disposeStage():void
		{
			if(this._stageExists){
				// remove from timeManager
				timeMgr.removeAnimatedObject(this);
				
				DisplayObjectUtils.removeAllChildren(this._gameStage);
				this._gameStage = null;
				this._stageExists = false;
			}
		}
		
		/**
		 * Get layer by id
		 * @param index
		 * @param allocateIfAbsent
		 * @return 
		 */
		public function getLayer(index:int, allocateIfAbsent:Boolean = false):DisplayObjectSceneLayer
		{
			// Maybe it already exists.
			if(_layers[index])
				return _layers[index];
			
			if(allocateIfAbsent == false)
				return null;
			
			// Allocate the layer.
			_layers[index] = generateLayer(index);
			
			// Order the layers. This is suboptimal but we are probably not going
			// to be adding a lot of layers all the time.
			DisplayObjectUtils.removeAllChildren(gameStage);
			
			var n:int = _layers.length;
			for(var i:int=0; i<n; i++)
			{
				if (_layers[i])
					gameStage.addChild(_layers[i]);
			}
			
			// Return new layer.
			return _layers[index];
		}
		
		/**
		 * Add a renderer component to level stage
		 * @param dor
		 */
		public function add(dor:DisplayObjectRenderer):void
		{
			// Add to the appropriate layer.
			var layer:DisplayObjectSceneLayer = getLayer(dor.layerIndex, true);
			layer.add(dor);
			if (dor.displayObject)
				_renderers[dor.displayObject] = dor;
		}
		
		/**
		 * Remove a renderer component from level stage 
		 * @param dor
		 */
		public function remove(dor:DisplayObjectRenderer):void
		{
			var layer:DisplayObjectSceneLayer = getLayer(dor.layerIndex, false);
			if(!layer)
				return;
			
			layer.remove(dor);
			if (dor.displayObject)
				delete _renderers[dor.displayObject];
		}
		
		public function getRendererForDisplayObject(displayObject:DisplayObject):DisplayObjectRenderer
		{
			var current:DisplayObject = displayObject;
			
			// Walk up the display tree looking for a DO we know about.
			while (current)
			{
				// See if it's a DOR.
				var renderer:DisplayObjectRenderer = _renderers[current] as DisplayObjectRenderer;
				if (renderer)
					return renderer;
				
				// If we get to a layer, we know we're done.
				if(renderer is DisplayObjectSceneLayer)
					return null;
				
				// Go up the tree..
				current = current.parent;
			}
			
			// No match!
			return null;
		}
		
		/**
		 * onFrame Function
		 */
		public function onFrame():void
		{
			// Give layers a chance to sort and update.
			// actually _layers is a map, don't use for(;;) loop to iterate
			for each(var l:DisplayObjectSceneLayer in _layers)
			{
				l.onRender();
			}
		}
		
		// ==== !==== Protected Functions ======
		/**
		 * Convenience funtion for subclasses to control what class of layer
		 * they are using.
		 */
		protected function generateLayer(layerIndex:int):DisplayObjectSceneLayer
		{
			var retLayer:DisplayObjectSceneLayer;
			
			// Do we have that layer already specified?
			if (_layers && _layers[layerIndex])
				retLayer = _layers[layerIndex] as DisplayObjectSceneLayer;
			
			// Go with default.
			if (!retLayer)
				retLayer = new DisplayObjectSceneLayer();
			
			retLayer.name = "Layer" + layerIndex;
			
			return retLayer;
		}
		
	}
}