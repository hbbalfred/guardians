package engine.render2D.spritesheet
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import engine.framework.core.IPBManager;
	import engine.framework.debug.Logger;
	import engine.managers.AssetsManager;
	
	/**
	 * A pb mananger to manage all sprite sheets
	 * @author Tang Bo Hao
	 */
	public class SpriteSheetManager implements IPBManager
	{
		// >> Injection <<
		[PBInject] public var assetsMgr:AssetsManager;
		
		// >> Members <<
		protected var _spriteSheets:Dictionary;
		
		public function initialize():void
		{
			_spriteSheets = new Dictionary;
		}
		
		public function destroy():void
		{
			var id:*;
			for(id in _spriteSheets)
			{
				_spriteSheets[ id ].destroy();
				delete _spriteSheets[ id ]; 
			}
			_spriteSheets = null;
		}
		
		/**
		 * Get a Sprite Sheet by given id
		 * @param id
		 * @return
		 */
		public function getSpriteSheetByID(id:String):BaseSpriteSheet
		{
			return _spriteSheets[id];
		}
		
		/**
		 * Generate a new sprite sheet from a image
		 * @param id
		 * @param imagefileKey
		 * @param divider
		 * @param firstgid
		 */
		public function geneSpriteSheetFromBitmap(id:String, imagefileKey:String, divider:ISpriteSheetDivider, firstgid:int = 0):void
		{
			if(_spriteSheets[id]){
				Logger.warn(this, "geneSpriteSheetFromBitmap", "Sprite ID exists");
				return;
			}
			
			var data:Bitmap = assetsMgr.getItemSync( imagefileKey );
			if( data && data is Bitmap ){
				var ss:SpriteSheet = new SpriteSheet;
				ss.divider = divider;
				ss.image = data;
				ss.firstGID = firstgid;
				_spriteSheets[id] = ss;	
			}
		}
		
		/**
		 * Generate a new sprite sheet from mc
		 * @param id, spritesheet id
		 * @param domain, id of ApplicationDomain
		 * @param classname, custom movieclip
		 */
		public function geneSpriteSheetFromMovieClip(id:String, domain:String, classname:String):void
		{
			if(_spriteSheets[id]){
				Logger.info(this, "geneSpriteSheetFromMovieClip", "Sprite ID exists");
				return;
			}
			
			var mcCls:Class = assetsMgr.getClass(domain,classname); 
			
			var ss:SWFSpriteSheet = new SWFSpriteSheet;
			ss.create( new mcCls(), classname, domain );
			_spriteSheets[id] = ss;
		}
		
	}
}