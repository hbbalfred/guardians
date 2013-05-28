package engine.tile
{
	import engine.framework.time.TickedComponent;
	
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;

	/**
	 * A component with TileMap Feature
	 * This Component Depend on DisplayObjectRenderer 
	 * @author Tang Bo Hao
	 */
	public class TileComponent extends TickedComponent implements ITile
	{	
		// >> Injection << 
		[PBInject] public var tilemap:TileMap;
		
		// >> Binding <<
		protected var _pos:Point;
		protected var _zindex:Number;
		
		public function set position(v:Point):void	{	
			_pos = v;
			if(tileid != tilemap.getTileId( v )){
				_tileDirty = true;
			}
		}
		public function get position():Point		{	return _pos;}
		
		public function set z(v:Number):void	{ 	_zindex = v;	}
		public function get z():Number			{	return _zindex; }
		
		// >> Memebers <<
		protected var _tileid:int;
		private var _tileDirty:Boolean = false;
		
		public function set tileid(v:int):void	{	_tileid = v;	}
		public function get tileid():int		{	return _tileid;	}
		
		// >> Signals <<
		public const on_ItemAddedToTile:Signal = new Signal(ITile);
		public const on_ItemRemoveFromTile:Signal = new Signal(ITile);
		
		/**
		 * @inheritDoc
		 */
		override protected function onAdd():void
		{
			super.onAdd();
			
			tilemap.updateItem(this);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onRemove():void
		{
			super.onRemove();
			
			this.position = null;
			tilemap.updateItem(this);
		}
		
		/**
		 * Game Entity Update
		 */		
		override public function onTick():void
		{
			super.onTick();
			
			if(_tileDirty){
				tilemap.updateItem(this);
				_tileDirty = false;
			}
		}
		
		public function itemAddedToTile(item:ITile):void
		{
			this.on_ItemAddedToTile.dispatch(item);
		}
		
		public function itemRemovedFromTile(item:ITile):void
		{
			this.on_ItemRemoveFromTile.dispatch(item);
		}
	}
}