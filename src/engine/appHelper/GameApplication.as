package engine.appHelper
{	
	import engine.EngineContext;
	import engine.framework.debug.Console;
	import engine.framework.debug.Logger;
	import engine.framework.input.KeyboardManager;
	import engine.framework.property.PropertyManager;
	import engine.framework.time.TimeManager;
	import engine.managers.AssetsManager;
	import engine.managers.BehaviorManager;
	import engine.managers.FontManager;
	import engine.managers.LayerManager;
	import engine.managers.ModelManager;
	import engine.managers.RendererManager;
	import engine.managers.SoundManager;
	import engine.managers.TipManager;
	import engine.managers.ViewManager;
	import engine.tween.TweenManager;
	import engine.ui.UICompFactory;
	import engine.utils.AppUtils;
	import engine.utils.FixMouseWheel;
	import engine.utils.RenderUtils;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Common application entry class
	 * @author Tang Bo Hao
	 */
	
	[SWF(frameRate="32",wmode="direct")]
	public class GameApplication extends Sprite
	{
		// Engine for current Game.
		public var gameContext:EngineContext = new EngineContext();
		private var _config:Configuration;
		
		public function GameApplication()
		{
			if (stage){
				this.init();
			}else{
				this.addEventListener(Event.ADDED_TO_STAGE, this.init);
			}
		}
		
		private function init(evt:Event = null):void
		{
			if(evt != null){
				this.removeEventListener(Event.ADDED_TO_STAGE, this.init);
			}
			
			registerManagers();
			
			// Stage scale mode - Set it so that the stage resizes properly.
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			
			// frame Rate
			stage.frameRate = _config.FRAME_RATE;
			
			// Set app context menu
			stage.showDefaultContextMenu = false;
			
			var customMenuItems:Array = new Array;
			var version:String = _config.VERSION;
			
			// Check Game built mode and then Set Context Menu
			if(AppUtils.isDebugBuild()){
				customMenuItems.push(new ContextMenuItem("This is debug environment!"));
				customMenuItems.push(new ContextMenuItem("Version: "+version));
			}else{
				customMenuItems.push(new ContextMenuItem("Product by BoisGames Studio!"));
				customMenuItems.push(new ContextMenuItem("Version: "+version));
			}
			
			// Context menu
			resetContextMenu();
			this.contextMenu.customItems = customMenuItems;			
			
			// Set stage to some utilities
			RenderUtils.stage = stage;
			
			// hack for mac os mouse wheel
			FixMouseWheel.setup(stage);
			
			// run startup
			startup();
		}
		
		private function registerManagers():void
		{
			// Set up the root group for the game and register some managers
			// managers. Managers are available via dependency injection to the
			// game scenes and objects.
			gameContext.initialize();
			// Inject Stage
			gameContext.owningGroup.registerManager(GameApplication, this);
			gameContext.owningGroup.registerManager(Stage, stage);
			// Inject Main PBE Managers
			gameContext.owningGroup.registerManager(PropertyManager, new PropertyManager());
			gameContext.owningGroup.registerManager(TimeManager, new TimeManager());
			gameContext.owningGroup.registerManager(KeyboardManager, new KeyboardManager());
			
			// Build check  - Logger Setting
			if(!AppUtils.isDebugBuild()){
				Logger.disable();
			}else{ 
				Logger.startup(stage);
				gameContext.registerManager(Console, new Console()); // enable console in debug mode
			}
			
			// global error events for release
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			
			// Inject Game Engine Managers
			gameContext.registerManager(EngineContext, gameContext);
			gameContext.registerManager(TweenManager, new TweenManager);
			gameContext.registerManager(RendererManager, new RendererManager);
			gameContext.registerManager(AssetsManager, new AssetsManager);
			gameContext.registerManager(LayerManager, new LayerManager);
			gameContext.registerManager(ModelManager, new ModelManager);
			gameContext.registerManager(FontManager, new FontManager);
			gameContext.registerManager(SoundManager, new SoundManager);
			gameContext.registerManager(BehaviorManager, new BehaviorManager);
			gameContext.registerManager(UICompFactory, new UICompFactory);
			gameContext.registerManager(ViewManager, new ViewManager);
			gameContext.registerManager(TipManager, new TipManager);
			
			// Set Config
			_config = getConfiguration();
			gameContext.registerManager(Configuration, _config);
		}
		
		/**
		 * Global Error Handler
		 * @param e
		 */
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{
			// avoid the popup in debug player
			e.preventDefault();
			
			var message:String;
			
			if( (e.error is Error) && AppUtils.isDebugPlayer() )
				message = e.error.getStackTrace();
			else
				message = e.error.toString();
			
			Global_Error.dispatch( "[UncaughtError]" + message );
		}
		
		protected function getConfiguration():Configuration
		{
			return new Configuration;
		}
		
		/**
		 * To be extended by child
		 */
		protected function startup():void
		{
			
		}
		
		// === Application General Functions ===
		public const Global_Error:Signal = new Signal;
		
		/**
		 * Get FlashVar
		 * @param String
		 * @return String
		 */
		public function getFlashVar(__parameter:String): String {
			return LoaderInfo(this.loaderInfo).parameters[__parameter];
		}
		
		public function resetContextMenu(): void {
			// Clears the menu
			this.contextMenu = new ContextMenu();
			this.contextMenu.hideBuiltInItems();
			
			//var mi:ContextMenuItem = new ContextMenuItem("Toggle Fullscreen");
			//mi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleFullScreen);
			//Global.app.contextMenu.customItems.push(mi);
		}
		
		/**
		 * Set to some fullscreen status
		 * @param fullscreen
		 * 
		 */
		public function setFullScreen(fullscreen:Boolean):void
		{
			if (this.stage){
				try {
					if (fullscreen){
						this.stage.displayState = StageDisplayState.FULL_SCREEN;
					} else {
						this.stage.displayState = StageDisplayState.NORMAL;
					};
				} catch(err:SecurityError) {
				}
			};
		}
		/**
		 * Check if current is fullscrenn
		 * @return 
		 */
		public function isFullScreen():Boolean
		{	
			return stage.displayState == StageDisplayState.FULL_SCREEN;
		}
		/**
		 * toggle FullScreen
		 */
		public function toggleFullScreen():void
		{
			setFullScreen(isFullScreen() == false);
		}
	}
}