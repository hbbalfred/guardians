package engine.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	
	/**
	 * Utilities Class for MovieClip 
	 * @author Tang Bo Hao
	 */
	public class DisplayObjectUtils 
	{
		public static const FLIP_HORIZONTAL:String = "flipHorizontal";
		public static const FLIP_VERTICAL:String = "flipVertical";
		
		/**
		 * Adjust DisplayObject Size
		 * @param display
		 * @param maxWidth
		 * @param maxHeight
		 */
		public static function adjustSize( display:DisplayObject, maxWidth:Number, maxHeight:Number):void
		{
			// first width
			var width:Number = Math.min( display.width, maxWidth);
			if( display.width != width ){
				display.width = width;
				display.height = display.scaleX / display.scaleY * display.height;
			}
			// then height
			var height:Number = Math.min( display.height, maxHeight);
			if( display.height != height ){
				display.height = height;
				display.width = display.scaleY  / display.scaleX * display.width;
			}
		}
		
		/**
		 * Remove all children from a container 
		 * @param container
		 */
		public static function removeAllChildren(container:DisplayObjectContainer):void
		{
			if (container != null){
				// fp 11
				if(container["removeChildren"] is Function)
				{
					container.removeChildren(0);
				}
				else
				{
					while ( container.numChildren ) 
						container.removeChildAt( container.numChildren - 1 );
				}
			}
		}
		
		/**
		 * Method for flipping a DisplayObject 
		 * @param obj DisplayObject to flip
		 * @param orientation Which orientation to use: PBUtil.FLIP_HORIZONTAL or PBUtil.FLIP_VERTICAL
		 * 
		 */		
		public static function flipDisplayObject(obj:DisplayObject, orientation:String):void
		{
			var m:Matrix = obj.transform.matrix;
			 
			switch (orientation) 
			{
				case FLIP_HORIZONTAL:
					m.a = -1;
					m.tx = obj.width + obj.x;
					break;
				case FLIP_VERTICAL:
					m.d = -1;
					m.ty = obj.height + obj.y;
					break;
			}
			
			obj.transform.matrix = m;
		}		
		
		/**
		 * Recursively searches for an object with the specified name that has been added to the
		 * display hierarchy.
		 * 
		 * @param name The name of the object to find.
		 * 
		 * @return The display object with the specified name, or null if it wasn't found.
		 */
		public static function findChild(name:String, displayObjectToSearch:DisplayObject):DisplayObject
		{
			return _findChild(name, displayObjectToSearch);
		}
		
		protected static function _findChild(name:String, current:DisplayObject):DisplayObject
		{
			if (!current)
				return null;
			
			if (current.name == name)
				return current;
			
			var parent:DisplayObjectContainer = current as DisplayObjectContainer;
			
			if (!parent)
				return null;
			
			for (var i:int = 0; i < parent.numChildren; i++)
			{
				var child:DisplayObject = _findChild(name, parent.getChildAt(i));
				if (child)
					return child;
			}
			
			return null;
		}
		
		/**
		 * Init button's stop script
		 */
		public static function initStopScript(mc:MovieClip):void{
			var labels:Array = mc.currentLabels;
			if (labels.length > 0){ // if have labels
				labels.forEach(function(framelabel:FrameLabel, ...rest):void{
					mc.addFrameScript(framelabel.frame - 2, mc.stop);
				});
				mc.addFrameScript((mc.totalFrames - 2), mc.stop);
			} else { // if not have labels, set 4 stops
				var index:int = 0,
					len:int = mc.totalFrames;
				while (index < len) {
					mc.addFrameScript(index, mc.stop);
					index++;
				}
			}
		}
		
		/**
		 * wrap a displayObject with a new DisplayObjectContainer 
		 * @param origin
		 * @param wrapper
		 */
		public static function wrapDisplayObject( display:DisplayObject, wrapper:DisplayObjectContainer ):void
		{
			wrapper.x = display.x;
			wrapper.y = display.y;
			if(display.parent)	display.parent.addChildAt(wrapper, display.parent.getChildIndex(display));
			display.x = 0;
			display.y = 0;
			wrapper.addChild(display);
		}
	}
} 
