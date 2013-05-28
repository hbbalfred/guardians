package engine.managers
{
	import engine.framework.core.IPBManager;
	
	import flash.utils.Dictionary;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * the manager to Binding Model and  
	 * @author Tang Bo Hao
	 * 
	 */
	public class ModelManager implements IPBManager
	{
		private var _keyBindingSignalsLib:Dictionary = null;
		
		/**
		 * Constructer
		 */
		public function initialize():void
		{
			this._keyBindingSignalsLib = new Dictionary(false);
		}
		
		/**
		 * Destructer
		 */
		public function destroy():void
		{
			var signal:Signal;
			for(var key:* in this._keyBindingSignalsLib){
				signal = this._keyBindingSignalsLib[key] as Signal;
				if(signal) signal.removeAll();
			}
			this._keyBindingSignalsLib = null;
		}
		
		/**
		 * update related value of the model
		 * @param obj
		 */
		public function updateModel(obj:*):void
		{
			var bindingSignal:ISignal = this._keyBindingSignalsLib[obj];
			
			if(!bindingSignal) return;
			
			bindingSignal.dispatch(obj);
		}
		
		/**
		 * bind resource to a function
		 * @param vo the target model vo
		 * @param func this function to call
		 * @param autoExec call the function when finish binding
		 */
		public function bindVO(vo:*, func:Function, autoExec:Boolean = false):void
		{
			var bindingSignal:Signal;

			bindingSignal = this._keyBindingSignalsLib[vo];
			if ( !bindingSignal )
			{
				bindingSignal = new Signal;
				this._keyBindingSignalsLib[vo] = bindingSignal;
			}
			
			bindingSignal.add(func);
			
			if(autoExec){
				func(vo);
			}
		}
		
		/**
		 * unbind resource to a function
		 * @param vo the target model vo
		 * @param func
		 */
		public function unbindVO(vo:*, func:Function):void
		{
			var bindingSignal:Signal = _keyBindingSignalsLib[vo];
			if(bindingSignal){
				bindingSignal.remove(func);
				if(bindingSignal.numListeners == 0){
					delete _keyBindingSignalsLib[vo];
				}
			}
		}
		
		/**
		 * Unbind all callback f
		 * @param name
		 */
		public function unbindAll(vo:*):void
		{
			var bindingSignal:Signal = _keyBindingSignalsLib[vo];
			if(bindingSignal){
				bindingSignal.removeAll();
				delete _keyBindingSignalsLib[vo];
			}
		}
	}
}