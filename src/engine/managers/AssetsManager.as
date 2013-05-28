package engine.managers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.media.SoundLoaderContext;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.BinaryItem;
	import br.com.stimuli.loading.loadingtypes.JSONItem;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import engine.framework.core.IPBManager;
	import engine.framework.debug.Logger;
	import engine.task.AsyncFunctionTask;
	import engine.task.ParallelTask;
	import engine.utils.ObjectUtils;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * Asset manager
	 * @author Tang Bo Hao
	 */
	public class AssetsManager implements IPBManager
	{	
		public static const DEFAULT_DOMAIN:String = 'default';

		private static const TYPE_JSON:String = "json";
		private static const TYPE_BINARY:String = "my_binary";
		
		// static variables
		private static var c_domainLib:Object = {};
		// item cache is used to speed up item getting
		private static var c_itemCache:Object = {};
		private static var c_loader:BulkLoader = (function():BulkLoader{
			BulkLoader.registerNewType( "json", TYPE_JSON, JSONItem );
			BulkLoader.registerNewType( "lua", TYPE_BINARY, BinaryItem );
			return BulkLoader.createUniqueNamedLoader();
		})();
		private static var c_loadedBundle:Object= {};
		private static var c_assetsConfig:Object;
		private static var c_configPattern:Object = {};
		
		/**
		 * Clear Loader and cache
		 */
		public static function clear():void
		{
			c_loader.clear();
			c_itemCache = {};
		}
		
		// >> Signals <<
		protected var _loadingComplated:ISignal;
		protected var _loadingProgress:ISignal;
		private var _rootPath:String;
		
		// >> Variable <<
		// assets basic variables
		protected var _appDomain:ApplicationDomain = null;
		
		// >> Constructor <<
		
		public function initialize():void
		{
			_appDomain = ApplicationDomain.currentDomain;
			
			// set domain
			c_domainLib[DEFAULT_DOMAIN] = _appDomain;
		}
		
		// >> Destructor <<
		public function destroy():void
		{	
			this._appDomain = null;
		}
		
		// >> Accessor <<
		public function get LoadingComplated():ISignal
		{
			_loadingComplated ||= new Signal();
			return _loadingComplated;
		}
		public function get LoadingProgress():ISignal
		{
			_loadingProgress ||= new Signal();
			return _loadingProgress;
		}
		
		public function set rootPath( value:String ):void{
			_rootPath = value || "";
		}
		public function get rootPath():String { return _rootPath; }
		
		/**
		 * Loading assets by a json configuration file
		 * @param configURL
		 * @param autostart if start load game assets automatically
		 * @example bundle json format:
		 * {
		 * 		path:"http://localhost/assets/",
		 * 		groupname1:[
		 * 			{
		 * 				domain: "image",
		 * 				path:"img/",
		 * 				items:[
		 * 					{
		 * 						id: "a",
		 * 						file: "a.jpg",
		 * 					}
		 * 				]
		 * 			}
		 * 		],
		 * 		groupname2:{
		 * 			path:"sounds/",
		 * 			items:[]
		 * 		}
		 * }
		 */
		public function loadAssetsConfig(configURL:String, autostart:Boolean = false):void
		{
			this.addAsset(configURL);
			this.LoadingComplated.addOnce(function(...args):void{
				setAssetsConfig( c_loader.getContent(configURL), autostart );
			});
			this.startLoading();
		}
		
		/**
		 * Directly set assets config
		 * @param cfgJSON
		 * @param autostart
		 */
		public function setAssetsConfig( cfgJSON:Object, autostart:Boolean = false ):void{
			c_assetsConfig = cfgJSON;
			if(c_assetsConfig == null) throw new Error("Error to load assests config");
			
			var rootpath:String = c_assetsConfig['path'];
			for(var key:String in c_assetsConfig){
				if(key == "path") continue;
				// if match ^\$(\w)\$, set as a pattern
				var match:Array = key.match(/^\$(\w+)\$/);
				if(match && match.length > 1){
					c_configPattern[match[1]] = c_assetsConfig[key];
				}
				if(autostart){
					this.addAssetsBundleGroup(key);
				}
			}
			if(autostart){
				this.startLoading();
			}
		}
		
		
		/**
		 * add assets by assets bundle
		 * Analyse bundle group and add to laoder
		 * @param groupName
		 * @return assets keys in bundle
		 * @example the group should have parts like the following object
		 * 		{
		 * 			domain: "image",
		 *			path:"img/",
		 *			items:[
		 *				{
		 *					id: "a",
		 *					file: "a.jpg",
		 *				}
		 *			]
		 *		}
		 */
		public function addAssetsBundleGroup(groupName:String, pattern:String = null, vo:Object = null, version:String = null):Array
		{
			if(!c_assetsConfig )	return null;
			if(!pattern && c_assetsConfig[groupName] == null) return null;
			if(pattern && c_configPattern[pattern] == null) return null;
			
			// if has pattern, based on Pattern to generate a bundle group
			if(pattern && vo){
				var config:Object = ObjectUtils.cloneObject( c_configPattern[pattern] );
				var replReg:RegExp = /\[(\w+)\]/g;
				config = ObjectUtils.deepReplaceString( config, replReg, vo);
				c_assetsConfig[groupName] = config;
			}
			
			// General add Assets Bundle
			const rootpath:String = _rootPath + c_assetsConfig['path'];
			
			var group:Object = c_assetsConfig[groupName];
			
			var parts:Array;
			var keys:Array = new Array;
			// map to array
			switch(ObjectUtils.typeOf(group)){
				case 'array':
					parts = group as Array;
					break;
				case 'object':
					parts = [group];
					break;
				default:
					return null;
			}
			
			// add all parts
			parts.forEach(function(part:Object, ...rest):void{
				var partdomain:String = part.domain as String;
				var partpath:String = part.path as String;
				var items:Array = part.items as Array;
				if(partdomain && partpath != null && items){
					items.forEach(function(item:Object, ...nouse):void{
						keys.push(item.id);
						var url:String = rootpath + partpath + item.file;
						if( version ) url += "?v=" + version;
						this.addAsset( url, { id : item.id, domain: partdomain } );
					}, this);
				}
			}, this);
			
			// Set bundle Loaded
			this.LoadingComplated.addOnce(function(...rest):void{
				c_loadedBundle[groupName] = true;
			});
			
			return keys;
		}
		
		/**
		 * check if bundle loaded
		 */
		public function isBundleLoaded(groupName:String):Boolean
		{
			return !!c_loadedBundle[groupName];
		}
		
		public function getBundleKeys(groupName:String):Array
		{
			if(!c_assetsConfig || !c_assetsConfig[groupName]) return null;
			
			var group:Array;
			var keys:Array;
			
			// map to array
			switch(ObjectUtils.typeOf(c_assetsConfig[groupName])){
				case 'array':
					group = c_assetsConfig[groupName] as Array;
					break;
				case 'object':
					group = [c_assetsConfig[groupName]];
					break;
				default:
					return null;
			}
			
			// get all keys
			keys = new Array; 
			group.forEach(function(part:Object, ...rest):void{
				var items:Array = part.items as Array;
				if(items){
					items.forEach(function(item:Object, ...nouse):void{
						keys.push( item.id ); 
					}, this);
				}
			}, this);
			
			return keys;
		}
		
		/**
		 * add a list of assets
		 * @param urls, assets loading url
		 * @param options, all assets use the same loader properties
		 */
		public function addAssets(urls:Array, options:Object = null ):void
		{
			urls.forEach(function(url:String, ...args):void{
				addAsset(url, options);
			});
		}
		
		/**
		 * add a asset to be prepared to load
		 * @param domain asset context domain
		 * @param url, asset loading url
		 * @param options, asset loader properties
		 * <ul>
		 *  <li>domain - ApplicationDomain id</li>
		 *  <li>more - see bulkloader.add()</li>
		 * </ul> 
		 */
		public function addAsset(url:String, options:Object = null ):LoadingItem
		{
			options ||= {};
			
			var domain:String;
			if(options['domain'] && options['domain'] is String){
				domain = options['domain'];
				delete options['domain'];
			}else{
				domain = DEFAULT_DOMAIN;
			}
			
			var appDomain:ApplicationDomain = c_domainLib[domain] as ApplicationDomain;
			var context:LoaderContext;
			
			// if not domain, create a new ApplicationDomain
			if(!appDomain){
				c_domainLib[domain] = appDomain = new ApplicationDomain(this._appDomain);
			}
			
			if(!options["nocontext"]){
				// if not a defualt loader context, we should use a new load context
				var checkPolicyFile:Boolean = Boolean(url.indexOf(_rootPath) < 0);
				var fileType:String = url.substr( url.lastIndexOf('.') + 1 );
				if( BulkLoader.SOUND_EXTENSIONS.indexOf(fileType ) >= 0 ){
					options.context = new SoundLoaderContext();
				}else{
					options.context = new LoaderContext(checkPolicyFile, appDomain, SecurityDomain.currentDomain);
				}
			}
			
			return c_loader.add(url, options); 
		}
		
		/**
		 * start load assets
		 * @param conn using how many connections default is unlimited -1
		 */
		public function startLoading(conn:int = -1):void
		{
			c_loader.addEventListener(BulkProgressEvent.PROGRESS, on_progress);
			c_loader.addEventListener(BulkProgressEvent.COMPLETE, on_complete);
			c_loader.addEventListener(BulkLoader.ERROR, on_error);
			c_loader.start(conn);
		}
		
		/**
		 * check if the item is loaded
		 * @param key
		 * @return
		 */
		public function hasItem(key:String):Boolean{
			return c_loader.hasItem(key);
		}
		
		
		/**
		 * Get Item by bundle name
		 * @param groupName
		 * @param callback
		 * @param thisObj
		 * @param clearMemory
		 * @param bundleid
		 */
		public function getBundleItems(groupName:String, callback:Function, thisObj:* = null, clearMemory:Boolean = false):void
		{
			if(!isBundleLoaded(groupName)){
				// Set bundle Loaded
				this.LoadingComplated.addOnce(function(...rest):void{
					c_loadedBundle[groupName] = true;
				});
			}
			
			this.getItems(this.getBundleKeys(groupName), null, callback, thisObj, clearMemory);
		}
		
		/**
		 * Get Items
		 * @param keys
		 * @param options
		 * @param callback
		 * @param thisObj
		 * @param clearMemory
		 */
		public function getItems(keys:Array, options:Object, callback:Function, thisObj:* = null, clearMemory:Boolean = false):void
		{
			var retData:Array = new Array;
			var parTask:ParallelTask = new ParallelTask;
			
			keys.forEach(function(key:String, ...rest):void{
				parTask.addCommand(new AsyncFunctionTask(thisObj, function(next:Function):void{
					getItem(key, options, function (err:Error, data:*):void{
						if(err){
							next(false);
						}
						else{
							retData[key] = data;
							next(true);
						}
					}, thisObj, clearMemory);
				}));
			});
			
			parTask.sig_complete.addOnce(function():void{
				parTask.sig_fail.removeAll();
				callback.call(thisObj, null, retData);
			});
			parTask.sig_fail.addOnce(function():void{
				parTask.sig_complete.removeAll();
				callback.call(thisObj, new Error("Load Fail"), null);
			});
			parTask.start();
		}
		
		/**
		 * async getting item function, if not loaded, then load it
		 * @param key default key is item url
		 * @param callback function(err, data)
		 * @param thisObj the 'this' object in callback function
		 * @param clearMemory
		 * @param nocache
		 */
		public function getItem(key:String, options:Object, callback:Function, thisObj:* = null, clearMemory:Boolean = false):void
		{
			options ||= {};
			var loader:BulkLoader = c_loader;
			
			var content:Object = loader.getContent(key);
			if(content == null) // if not loaded
			{				
				if(!loader.get(key)) // if not exist, we should load it 
				{
					var url:String = options['url'] || key;
					options['id'] ||= key;
					// add
					var loadingItem:LoadingItem = this.addAsset(url, options);
					loadingItem.addEventListener(Event.COMPLETE, function (e:Event):void{
						callback.call(thisObj, null,getItemSync(key,clearMemory) );
					}, false, 0, true);
					loadingItem.addEventListener(ErrorEvent.ERROR, function(evt:Event):void {
						loader.removeFailedItems();
						callback.call(thisObj, new Error("File cannot be loaded"), null);
					}, false, 0, true);
					// load it
					loader.start();
				}
			}
			else // if loaded, callback
			{
				callback.call(thisObj, null,getItemSync(key,clearMemory) );
			}
		}
		
		public function getItemSync( key:String, clearMemory:Boolean = false ):*{
			var loader:BulkLoader = c_loader;
			// handle raw object
			var rawitem:LoadingItem = loader.get(key);
			var cached:Object = c_itemCache[key];
			var retObj:*;
			var cacheLoader:Loader;
			
			if(!rawitem) return null;
			
			switch(rawitem.type){
				case BulkLoader.TYPE_IMAGE: // callback a new Image with the BitmapData
					var bmd:BitmapData;
					if(cached && cached is BitmapData){// if cached, create a new bmp by bmpdata
						bmd = BitmapData(cached);
						retObj = new Bitmap(bmd);
					}else{
						if( rawitem.content is Bitmap ){
							retObj = loader.getBitmap(key, clearMemory);
							c_itemCache[key] = bmd = Bitmap(retObj).bitmapData;
						}else{
							retObj = rawitem.content;
						}
					}
					break;
				case BulkLoader.TYPE_MOVIECLIP: //if clearMemory = true callback the instance, if false, callback a copy of the swf file
					// if clearmemory, don't cache it and return directly
					if(clearMemory){
						retObj = loader.getSprite(key, true) || rawitem.content;
					}else{// if false, cache its byte array
						if(!cached){ // cache it, then callback
							retObj = loader.getSprite(key, false);
							c_itemCache[key] = cached = retObj.loaderInfo.bytes;
						}else{ // if cached, create a new loader to load bytes
							cacheLoader = new Loader;
							cacheLoader.loadBytes(ByteArray(cached), rawitem._context);
							retObj = cacheLoader;
						}
					}
					break;
				case BulkLoader.TYPE_SOUND: // callback sound file directly
					retObj = loader.getSound(key, clearMemory);
					break;
				case BulkLoader.TYPE_VIDEO: // callback video file directly
					retObj = loader.getNetStream(key, clearMemory);
					break;
				case BulkLoader.TYPE_TEXT: // callback the copy of the text
					retObj = new String(loader.getText(key, clearMemory));
					break;
				case BulkLoader.TYPE_XML: // callback the copy of the xml
					retObj = new XML(loader.getXML(key, clearMemory));
					break;
				case TYPE_BINARY: // callback binary directly
					retObj = loader.getBinary(key, clearMemory);
					break;
				case TYPE_JSON: // callback json
					retObj = loader.getContent(key, clearMemory);
					break;
				default:
					retObj = null;
					break;
			}
			return retObj;
		}
		
		/**
		 * Get a class from some domain
		 * @param domain
		 * @param name
		 * @return Class
		 */
		public function getClass(domain:String, name:String, showError:Boolean=true):Class
		{
			var currDomain:ApplicationDomain;
			if( domain ){
				currDomain = c_domainLib[domain];
			}else{
				currDomain = c_domainLib[DEFAULT_DOMAIN]
			}
			
			if(!currDomain) return null; 
			
			try{
				var ret:Object= currDomain.getDefinition(name);
				return ret as Class;
			}catch(ex:ReferenceError){
				if(showError) Logger.error(this, "getClass", ex.message);
			}
			return null;
		}
		
		// ==!=== protected functions ======
		/**
		 * on assets loading complete
		 * @param event
		 */
		protected function on_complete(event:BulkProgressEvent):void
		{
			c_loader.removeEventListener(BulkProgressEvent.PROGRESS, on_progress);
			c_loader.removeEventListener(BulkProgressEvent.COMPLETE, on_complete);
			c_loader.removeEventListener(BulkLoader.ERROR, on_error);
			
			// dispatch signal
			this.LoadingComplated.dispatch(event.bytesTotal, event.itemsLoaded);
		}
		
		/**
		 * On progress when loading
		 * @param event
		 */
		protected function on_progress(event:BulkProgressEvent):void
		{
			this.LoadingProgress.dispatch(event.weightPercent, event.bytesLoaded, event.bytesTotal, event.itemsLoaded, event.itemsTotal);
		}
		
		/**
		 * Remove failed item when meet error
		 * @param evt
		 */
		protected function on_error(evt:ErrorEvent):void
		{
			c_loader.removeFailedItems();
		}
	}
}