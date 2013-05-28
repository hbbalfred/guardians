/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package engine.render2D
{
    import engine.framework.time.AnimatedComponent;
    import engine.managers.RendererManager;
    import engine.utils.MathUtils;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Point;
    import flash.utils.Dictionary;

    /**
     * Base renderer for Rendering2D. It wraps a DisplayObject
	 * 
     * <p>The various other renderers inherit from DisplayObjectRenderer,
     * and rely on it for basic functionality.</p>
     *
     * <p>Normally, the DisplayObjectRenderer tries to update itself
     * every frame. However, you can suppress this by setting
     * registerForUpdates to false, in which case you will have to
     * call onFrame() manually if you change
     * something.</p>
     *
     * @see BitmapRenderer
     * @see SpriteSheetRenderer
     * @see MovieClipRenderer
     */
    public class DisplayObjectRenderer extends AnimatedComponent
    {	
		// >> Injection <<
		[PBInject] public var renderMgr:RendererManager;
		
		// Protected Members
		protected var _layerIndex:int = 0;
		protected var _lastLayerIndex:int = -1;
		protected var _zIndex:Number = 0;
		
		protected var _displayObject:DisplayObject;
		protected var _position:Point = new Point();
		protected var _origin:Point = new Point();
		// Private Memebers
		private var _zIndexDirty:Boolean;
		private var _layerIndexDirty:Boolean;
		private var _inScene:Boolean;
		private var _attachDeferDic:Dictionary;
		private var _attachList:Vector.<DisplayObjectRenderer>;
		private var _attachParent:DisplayObjectRenderer;
		
		// === ! ======= Accessors ==========
		/**
		 * @private
		 */
		public function set layerIndex(v:int):void
		{
			if(_layerIndex == v) return;
			
			_layerIndex = v;
			_layerIndexDirty = true;
		}
		public function get layerIndex():int {	return _layerIndex;	}
		
		/**
		 * the object current position
		 */
		public function set position(v:Point):void
		{
			if(!displayObject || !v)
				return;
			if(_position.x == v.x && _position.y == v.y)
				return;
			_position.x = v.x;
			_position.y = v.y;
			displayObject.x = v.x;
			displayObject.y = v.y;
		}
		public function get position():Point	{	return _position.clone();	}
		
		/**
		 * rotation by radians
		 */
		public function set rotation(v:Number):void
		{
			if(!displayObject) return;
			
			displayObject.rotation = MathUtils.getDegreesFromRadians(v);
		}
		
		/**
		 * the origin point of the object
		 */
		public function set origin(v:Point):void
		{
			if(_origin.equals(v)) return;
			_origin.x = v.x;
			_origin.y = v.y;
		}
		public function get origin():Point	{	return _origin.clone(); }
		
		/**
		 * display object in flash player 
		 */
		public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		/**
		 * The displayObject which this DisplayObjectRenderer will draw.
		 */
		public function set displayObject(value:DisplayObject):void
		{
			// Remove old object from scene.
			removeFromScene();
			
			removeChildren();
			
			_displayObject = value;
			
			addChildren();
			
			if(name && owner && owner.name)
				_displayObject.name = owner.name + "." + name;
			
			if(renderMgr){
				// Add new scene.
				addToScene();
			}
		}
		
		/**
		 * display object  
		 */
		public function get body():DisplayObject
		{
			return displayObject;
		}
		
		/**
		 * By default, layers are sorted based on the z-index, from small
		 * to large.
		 * @param value Z-index to set.
		 */
		public function set zIndex(value:Number):void
		{
			if (_zIndex == value)
				return;
			
			_zIndex = value;
			_zIndexDirty = true;
		}
		public function get zIndex():Number {	return _zIndex;	}
		
		
		/**
		 * attach a child display object render 
		 * this attach just defering to check display object whether created or defined
		 * notice: some properties (zIndex, layerIndex) is not used for the attached render
		 * @param dor
		 * @param top, attach on top depth, else bottom depth
		 */
		public function attach( dor:DisplayObjectRenderer, top:Boolean = true ):void
		{
			if(!_attachDeferDic) _attachDeferDic = new Dictionary;
			
			if( _attachDeferDic[ dor ] ) return;
			
			dor._attachParent = this;
			
			var da:DeferAttach = new DeferAttach( this, dor, top, onDeferAttach );
			da.timeMgr = timeManager;
			if( da.check() ){ attachReal( dor, top ); return; }
			
			_attachDeferDic[ dor ] = da;
			this.timeManager.addAnimatedObject( da );
		}
		
		/**
		 * detach a child in the render if be contained.
		 * @param dor
		 */
		public function detach( dor:DisplayObjectRenderer ):void
		{
			dor._attachParent = null;
			
			if( _attachDeferDic[dor] )
			{
				this.timeManager.removeAnimatedObject(_attachDeferDic[dor]);
				delete _attachDeferDic[dor]; 
			}
				 
			detachReal( dor );
		}
		
		/**
		 * real attach 
		 * @param dor
		 * @param top
		 */
		private function attachReal( dor:DisplayObjectRenderer, top:Boolean ):void
		{
			var container:DisplayObjectContainer = this.displayObject as DisplayObjectContainer;
			if(!container) throw new Error("Error: the display object is NOT a container.");
			
			// lazy created
			if(!_attachList) _attachList = new Vector.<DisplayObjectRenderer>();
			// push in list
			var i:int = _attachList.indexOf( dor );
			if(i == -1)	_attachList.push( dor );
			// push in scene
			dor.removeFromScene();
			if( top )
				container.addChild( dor.displayObject );
			else
				container.addChildAt( dor.displayObject, 0 );
		}
		/**
		 * real detach 
		 * @param dor
		 */
		private function detachReal( dor:DisplayObjectRenderer ):void
		{
			var container:DisplayObjectContainer = this.displayObject as DisplayObjectContainer;
			if(!container) return; //throw new Error("Error: the display object is NOT a container.");
			
			if(!_attachList) return;
			var i:int = _attachList.indexOf( dor );
			if( i == -1 ) return;
			
			_attachList.splice( i,1 );
			if(dor.displayObject.parent){
				container.removeChild( dor.displayObject );
			}
			dor.addToScene();
		}
		/**
		 * defer attach 
		 * @param dor
		 */
		private function onDeferAttach( dor:DisplayObjectRenderer, top:Boolean ):void
		{
			this.timeManager.removeAnimatedObject( _attachDeferDic[ dor ] );
			delete _attachDeferDic[ dor ]
			attachReal( dor, top );
		}
		
		/**
		 * attach children in list 
		 */
		protected function addChildren():void
		{
			if(!_attachList) return;
			
			var container:DisplayObjectContainer = this.displayObject as DisplayObjectContainer;
			if(!container) return;
			
			var ob:DisplayObject;
			for(var i:int = 0; i < _attachList.length; ++i)
			{
				ob = _attachList[i].displayObject;
				if( ob.parent == container ) continue;
				container.addChild( ob );
			}
		}
		
		/**
		 * detach children in list
		 * 
		 */
		protected function removeChildren():void
		{
			if(!_attachList) return;
			
			var container:DisplayObjectContainer = this.displayObject as DisplayObjectContainer;
			if(!container) return;
			
			var ob:DisplayObject;
			for(var i:int = _attachList.length - 1; i > -1; --i)
			{
				ob = _attachList[i].displayObject;
				if( ob.parent == container )
					container.removeChild( ob );
			}
		}
		
		/**
		 * @inheritDoc 
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			
			if(_displayObject)
				_displayObject.name = owner.name + "." + name;
			
			addToScene();
			
			// 2012.11.18
			// hbb
			// force update one time!
			// since the onRemove would be involked in anytime (owner is destroied)
			onFrame();
		}
		
		/**
		 * @inheritDoc 
		 */
		override protected function onRemove() : void
		{
			if(_layerIndexDirty)
				throw new Error("Error: need set layer index before onAdd!");
			
			// detach all items in myself
			if(_attachList)
			{
				for(var i:int = _attachList.length - 1; i > -1; --i)
					detach( _attachList[i] );
				_attachList = null;
			}
			// destroy all prepare attach handlers
			if(_attachDeferDic)
			{
				for(var dor:* in _attachDeferDic)
				{
					this.timeManager.removeAnimatedObject( _attachDeferDic[dor] );
					delete _attachDeferDic[dor];
				}
				_attachDeferDic = null;
			}
			
			// detach from parent
			if(_attachParent && _attachParent._inScene)
				_attachParent.detach(this);
			
			// Remove ourselves from the scene when we are removed.
			removeFromScene();
			
			// defend exception above
			if(_displayObject && _displayObject.parent)
				_displayObject.parent.removeChild(_displayObject);
			
			super.onRemove();
		}
		
		protected function removeFromScene():void
		{
			if(_displayObject && _inScene)
			{
				this.renderMgr.remove(this);
				_inScene = false;
			}            
		}
		
		protected function addToScene():void
		{
			if(_attachParent)
				return;
			
			if(_displayObject && !_inScene)
			{                
				this.renderMgr.add(this);
				_inScene = true;
				
				_lastLayerIndex = _layerIndex;
				_layerIndexDirty = _zIndexDirty = false;
			}
		}
		
		override protected function doFrame():void
		{
			// Lookup and apply properties. This only makes adjustments to the
			// underlying DisplayObject if necessary.
			if (!owner)
				return;
			
			// Maybe we were in the right layer, but have the wrong zIndex.
			if (_zIndexDirty)
			{
				this.renderMgr.getLayer(_layerIndex, true).markDirty();
				_zIndexDirty = false;
			}
			
			// Make sure we're in the right layer and at the right zIndex in the scene.
			// Do this last to be more caching-layer-friendly. If we change position and
			// layer we can just do this at end and it works.
			if (_layerIndexDirty)
			{
				var tmp:int = _layerIndex;
				_layerIndex = _lastLayerIndex;
				
				if(_lastLayerIndex != -1)
					removeFromScene();
				
				_layerIndex = tmp;
				
				addToScene();
				
				_lastLayerIndex = _layerIndex;
				_layerIndexDirty = false;
			}
		}

    }
}
import engine.framework.time.IAnimated;
import engine.framework.time.TimeManager;
import engine.render2D.DisplayObjectRenderer;

class DeferAttach implements IAnimated
{
	public var timeMgr:TimeManager;
	public var parent:DisplayObjectRenderer;
	public var child:DisplayObjectRenderer;
	public var handler:Function;
	public var top:Boolean;
	public function DeferAttach( parent:DisplayObjectRenderer, child:DisplayObjectRenderer, top:Boolean, attachHandler:Function )
	{
		this.parent = parent;
		this.child = child;
		this.handler = attachHandler;
		this.top = top;
	}
	public function check():Boolean
	{
		return parent && child && parent.displayObject && child.displayObject;
	}
	
	public function onFrame():void
	{
		if( check() )
		{
			handler.apply( parent, [child, top] );
		}
		
		if(!parent.owner || !child.owner)
			timeMgr.removeAnimatedObject(this);
	}
}