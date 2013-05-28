package engine.render2D.interactive
{
	import engine.framework.core.PBComponent;
	import engine.framework.time.TickedComponent;
	import engine.framework.util.TypeUtility;
	import engine.ui.UICompFactory;
	import engine.ui.comps.UIInteractive;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	
	import org.osflash.signals.Signal;
	
	/**
	 * 2D Interactive Component
	 * Requires DisplayObjectRenderer
	 * Using UIInteractive to enable interative feature
	 * @author Tang Bo Hao
	 */
	public class InteractiveComponent extends PBComponent
	{
		[PBInject]
		public var uifactory:UICompFactory;
		
		public const sig_interactiveChanged:Signal = new Signal(UIInteractive);
		
		protected var _interative:UIInteractive;
		protected var _display:DisplayObject;
		
		// >> Accessors <<
		/**
		 * Get interactive object
		 * @return
		 */
		public function get interactive():UIInteractive{
			return _interative;
		}	
		
		/**
		 * Set the display object
		 * @param value
		 */
		public function set display(value:DisplayObject):void{
			if(_display == value) return;
			
			if(value == null || !(value is Sprite)) throw new Error("No DisplayObject exist!");
			
			_display = value;
			
			// Dispose Old one
			if(_interative) _interative.destroy();
			
			// Create a new one
			_display.name = "$interactive$" + (this.owner.name || TypeUtility.getObjectClassName(_display)) + "$$";
			_interative = uifactory.createUI(_display as InteractiveObject) as UIInteractive;
			
			// Dispatch the new one, old one is destroyed
			sig_interactiveChanged.dispatch( _interative );
		}
		
		// >> Overrides <<
		
		override protected function onRemove():void
		{
			sig_interactiveChanged.removeAll();
			
			if(_interative){
				_interative.destroy();
				_interative = null;
			}
			
			super.onRemove();
		}
		
	}
}