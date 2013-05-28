package engine.managers
{
	import com.soma.ui.BaseUI;
	import com.soma.ui.ElementUI;
	
	import engine.appHelper.GameApplication;
	import engine.framework.core.IPBManager;
	import engine.mvcs.EngineMediatorEvent;
	import engine.tween.TweenManager;
	import engine.utils.ObjectUtils;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	/**
	 * LayerManager defines all the layers in GUI
	 * @author Tang Bo Hao
	 */
	public class LayerManager implements IPBManager
	{
		protected static const DEFAULT_LAYER:String = "default"; 
		
		[PBInject] public var app:GameApplication;
		[PBInject] public var stage:Stage;
		[PBInject] public var tweenMgr:TweenManager;
		
		/* ==!====== Class Defination ======== */
		private var _baseUI:BaseUI = null;
		private var _layers:Dictionary = null;
		
		/**
		 * class constructor
		 */
		public function initialize():void
		{
			this._baseUI = new BaseUI(stage);
			this._layers = new Dictionary(true);
			
			var defaultLayer:LayerData = new LayerData;
			defaultLayer.layer = this.app;
			this._layers[DEFAULT_LAYER] = defaultLayer;
		}
		
		/**
		 * class destructor
		 */
		public function destroy():void
		{
			_baseUI = null;
			_layers = null;
		}
		
		/**
		 * Register a layer with name and layout, the layer will insert to index 0 of the app
		 * @param layerID
		 * @param uioptions layer options
		 * @return Sprite
		 */
		public function registerLayer(layerID:String, uioptions:Object, fxOption:Object = null, layerSprite:Sprite = null):void
		{
			var layerdata:LayerData = this._layers[layerID] as LayerData;
			if(!layerdata){
				layerdata = new LayerData;
				layerdata.layer = layerSprite || new Sprite;
				layerdata.layer.visible = false;
				this.app.addChildAt(layerdata.layer, 0);
				layerdata.uiOption = uioptions;
				// Check if need Layer FX
				if(fxOption && fxOption['start'] && fxOption['end'] && fxOption['param'])
				{
					layerdata.fxOption = fxOption;
				}
				this._layers[layerID] = layerdata; 
			}
		}
		
		/**
		 * add a view to a layer by name
		 * @param view
		 * @param layername
		 */
		public function addViewToLayer(view:Sprite, layerID:String = DEFAULT_LAYER ):void
		{
			layerID ||= DEFAULT_LAYER;
			
			var layerdata:LayerData = this._layers[layerID] as LayerData;
			if(layerdata){
				var layer:Sprite = layerdata.layer;
				var fxOption:Object = layerdata.fxOption;
				// Add to ElementUI layer 
				function addToLayer(child:Sprite):void{
					if ( !layer.visible ) 
						layer.visible = true;
					
					var ele:ElementUI = this._baseUI.add(child);
					ObjectUtils.setProperties(ele, layerdata.uiOption);
					ele.refresh();
					layer.addChild(child);
					layerdata.children++;
				}
				
				if(fxOption){
					addToLayer.call(this, view);
					view.visible = false;
					this.performFx(view, getFxOption(view, fxOption['end'] ), fxOption['param']
					, function(thisObj:Object):void{ // OnStart
						ObjectUtils.setProperties(view, getFxOption(view, fxOption['start']));
						view.visible = true;
					}
					, function(thisObj:Object):void{ // OnComplete
						view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_ACTIVATED, view));
					});
				}else{
					addToLayer.call(this, view);
					view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_ACTIVATED, view));
				}
			}else{
				throw new Error("No Layer name exists");
			}
		}
		
		/**
		 * remove a view from a layer by name
		 * @param view
		 * @param layername
		 */
		public function removeViewFromLayer(view:Sprite, layerID:String = DEFAULT_LAYER):void
		{
			layerID ||= DEFAULT_LAYER;
			
			var layerdata:LayerData = this._layers[layerID] as LayerData;
			if(layerdata){
				var layer:Sprite = layerdata.layer;
				var option:Object = layerdata.fxOption;
				
				if(layer.contains(view)){
					if(option){
						this.performFx(view, getFxOption(view, option['start'], !!option["reverse"]), option['param']
							, function(thisObj:Object):void{ // OnStart
								view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_DEACTIVATED, view));
							}
							, function(thisObj:Object):void{ // OnComplete
								removeFromLayer(view, layer, layerdata);
							});
					}else{
						view.dispatchEvent(new EngineMediatorEvent(EngineMediatorEvent.VIEW_DEACTIVATED, view));
						removeFromLayer(view, layer, layerdata);
					}
				}
			}else{
				throw new Error("No Layer name exists");
			}
		}
		// Remove from ElementUI layer
		private function removeFromLayer(child:Sprite, layer:Sprite, layerdata:LayerData):void
		{
			this._baseUI.remove(child);
			layer.removeChild(child);
			layerdata.children--;
			
			if( layerdata.children <=0 ){
				layerdata.children = 0;
				layer.visible = false;
			}
			
			// workaround for keyboard lose focus
			stage.focus = null;
		}
		
		// ====== Protected Function ======
		/**
		 * perform a view fx by ZTween
		 * @param view
		 * @param targetProp
		 * @param param
		 * @param onStart
		 * @param onComplete
		 */
		protected function performFx(view:Sprite, targetProp:Object, param:Object, onStart:Function, onComplete:Function):void
		{
			// remove old tween if exists
			tweenMgr.remove( view );
			// setup param
			param ||= {};
			param['onStart'] = onStart;
			param['onStartParams'] = [this];
			param['onComplete'] = onComplete;
			param['onCompleteParams'] = [this];
			tweenMgr.add(view, targetProp, param);
		}
		
		protected function getFxOption(view:Sprite, fxoption:Object, reverse:Boolean = false ):Object
		{
			var retObj:Object = {};
			var key:String, value:Object;
			var one:int = reverse ? -1 : 1;
			
			// check keys in options
			for( key in fxoption){
				if(!view.hasOwnProperty(key)) continue;
				
				value = fxoption[key];
				if(typeof value == "number"){
					retObj[key] = Number(value)* one;
				}else if(typeof value == "string"){
					if(String(value).charAt(0) == "-") 
						retObj[key] = view[key] - one * Number(String(value).substring(1));
					else
						retObj[key] = view[key] + one * Number(String(value).substring(1));
				}
			}
			return retObj;
		}
	}
}
import flash.display.Sprite;

class LayerData{
	public var layer:Sprite = null;
	public var uiOption:Object = null;
	public var fxOption:Object = null;
	public var children:int = 0;
}