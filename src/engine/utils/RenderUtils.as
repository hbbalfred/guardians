package engine.utils
{	
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * call function before Rendering
	 * Based on https://github.com/zeh/as3/blob/master/com/zehfernando/utils/RenderUtils.as
	 * @author Tang Bo Hao
	 */
	public class RenderUtils
	{
		// Properties
		protected static var functionsToCall:Vector.<Function> = new Vector.<Function>();
		
		// Create functions that are called prior to rendering
		protected static var isQueued:Boolean;
		
		// ===!=============== INTERNAL INTERFACE ============================
		//--------------------------------------------------------------------
		
		protected static function invalidate(): void {
			stage.invalidate();
		}
		
		protected static function queue(): void {
			if (!isQueued) {
				stage.addEventListener(Event.RENDER, onRenderStage);
				isQueued = true;
			}
		}
		
		protected static function executeQueue(): void {
			unQueue();
			
			while (functionsToCall.length > 0) {
				functionsToCall.shift()();
			}
			
			functionsToCall = new Vector.<Function>();
		}
		
		protected static function unQueue(): void {
			if (isQueued) {
				stage.removeEventListener(Event.RENDER, onRenderStage);
				isQueued = false;
			}
		}
		
		// ===!================= EVENT INTERFACE ========================
		//---------------------------------------------------------------
		
		protected static function onRenderStage(e:Event): void {
			executeQueue();
		}
		
		// ===!=============== PUBLIC INTERFACE =====================
		//-----------------------------------------------------------
		public static var stage:Stage;
		
		public static function addFunctionBeforeRendering(__function:Function): void {
			if (functionsToCall.indexOf(__function) == -1) {
				// Doesn't exist, so adds to the stack
				functionsToCall.push(__function);
			} else {
				// Exists, so moves to the end of the list
				functionsToCall.splice(functionsToCall.indexOf(__function), 1);
				functionsToCall.push(__function);
			}
			
			queue();
			invalidate();
		}
	}
}