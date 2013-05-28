package engine.tile
{
	import engine.framework.core.IPBManager;
	import engine.utils.MathUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * a Tile map collection with area slicing
	 * 
	 * @author hbb
	 * @author Tang Bo Hao
	 */
	public class TileMap implements IPBManager
	{
		// TileMap Info
		private var _width:Number;
		private var _height:Number;
		private var _tileSizeW:int;
		private var _tileSizeH:int;
		
		// Tile Info
		private var _tileWidth:Number;
		private var _tileHeight:Number;
		private var _tiles:Vector.<Dictionary>;
		
		/**
		 * Constructor
		 * 
		 * @param tileWidth the width of one tile 
		 * @param tileHeight the height of one tile
		 * @param tileSizeW how many tiles in W
		 * @param tileSizeH how many tiles in H
		 */
		public function TileMap( tileWidth:Number, tileHeight:Number, tileSizeW:int , tileSizeH:int = -1)
		{
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			_tileSizeW = tileSizeW;
			_tileSizeH = tileSizeH == -1 ? tileSizeW : tileSizeH;
			
			_width = _tileWidth * _tileSizeW;
			_height = _tileHeight * _tileSizeH;
			
			_tiles = new Vector.<Dictionary>( _tileSizeW * _tileSizeH, true );
		}
		
		// PB Initialize
		public function initialize():void
		{
			for(var i:int = _tiles.length - 1; i > -1; --i)
				_tiles[i] = new Dictionary(true);	
		}
		// PB Destroy
		public function destroy():void
		{
			clear();
			_width = _height = _tileSizeW = 0.0;
			_tileWidth = _tileHeight = 0;
			_tiles = null;
		}
		
		/**
		 * clear all grids for reuse 
		 * 
		 */
		public function clear():void
		{
			for(var i:int = _tiles.length - 1; i > -1; --i)
			{
				for(var ob:* in _tiles[i])
				{
					delete _tiles[i][ob];
				}
				_tiles[i] = null;
			}
		}
		/**
		 * add item into the grid
		 * @param ob
		 * 
		 */
		public function updateItem( ob:ITile ):void
		{  
			if(ob == null) return;
			
			var tile:Dictionary;
			var item:*;
			
			// Remove Item
			if(ob.tileid >= 0){
				tile = _tiles[ob.tileid];
				if(tile){
					delete tile[ob];
					for( item in tile){
						ITile(item).itemRemovedFromTile(ob);
					}					
				}
			}
			
			if(ob.position){
				// Add Item
				ob.tileid = getTileId( ob.position );
				tile = _tiles[ob.tileid];
				
				if( tile ) {
					for( item in tile){
						ITile(item).itemAddedToTile(ob);
					}
					
					tile[ob] = true;
				}
			}
		}
		
		/**
		 * get items from the grid where contains the specified point
		 * @param point
		 * @return all items in the grid
		 */
		public function getItemsAt( p:Point, z_index:Number = -1 ):Vector.<ITile>
		{
			var tile:Dictionary = getTile( p );
			return getItemsInTile( tile , z_index );
		}
		
		/**
		 * get items from the grid(s) where over the specified rectangle bound
		 * @param x, left side of rectangle
		 * @param y, top side of rectangle
		 * @param w, rectangle width
		 * @param h, rectangle height
		 * @return
		 */
		public function getItemsAtRect( rec:Rectangle , z_index:Number = -1 ):Vector.<ITile>
		{
			var tiles:Vector.<Dictionary> = new Vector.<Dictionary>;
			
			// add tile to tiles vector
			var rowStart:int = rec.y / _tileHeight;
			var rowEnd:int = rowStart + rec.height / _tileHeight;
			var colStart:int = rec.x / _tileWidth;
			var colEnd:int = colStart + rec.width / _tileWidth;
			
			rowStart = MathUtils.clamp(rowStart, 0, _tileSizeH);
			rowEnd = MathUtils.clamp(rowEnd, 0, _tileSizeH);
			colStart = MathUtils.clamp(colStart, 0, _tileSizeW);
			colEnd = MathUtils.clamp(colEnd, 0, _tileSizeW);
			
			var i:int ,j:int;
			for (i=rowStart; i<= rowEnd; i++){
				for( j=colStart; j<= colEnd; j++){
					tiles.push(_tiles[ i * _tileSizeW + j ]);
				}
			}
			return getItemsInTiles(tiles, z_index );
		}
		
		/**
		 * get items from the grid(s) where over the specified circle bound 
		 * @param x, circle center of x-axis
		 * @param y, circle center of y-axis
		 * @param r, circle radius
		 * @return
		 */
		public function getItemsAtCircle( p:Point, r:Number, z_index:Number = -1 ):Vector.<ITile>
		{
			var tiles:Vector.<Dictionary> = new Vector.<Dictionary>;
			var x:Number = p.x;
			var y:Number = p.y;
			
			// find tile to tiles vector
			var rowStart:int = Math.ceil( ( y - r ) / _tileHeight );
			var rowEnd:int = Math.floor( ( y + r ) / _tileHeight );
			var colStart:int = Math.ceil( ( x - r ) / _tileWidth );
			var colEnd:int = Math.floor( ( x + r ) / _tileWidth );
			
			rowStart = MathUtils.clamp(rowStart, 0, _tileSizeH);
			rowEnd = MathUtils.clamp(rowEnd, 0, _tileSizeH);
			colStart = MathUtils.clamp(colStart, 0, _tileSizeW);
			colEnd = MathUtils.clamp(colEnd, 0, _tileSizeW);
			
			var i:int ,j:int, dx:Number, dy:Number;
			for (i=rowStart; i<= rowEnd; i++){
				for( j=colStart; j<= colEnd; j++){
					dy = i * _tileHeight - y;
					dx = j * _tileWidth - x;
					if( dx*dx + dy*dy <= r*r ){
						tiles.push(_tiles[ i * _tileSizeW + j ]);
					}
				}
			}
			
			return getItemsInTiles(tiles, z_index );
		}
		
		/**
		 * Get a tile by x, y in map
		 * @param p Point
		 * @return
		 */
		public function getTile( p:Point ):Dictionary
		{
			return _tiles[getTileId(p)];
		}
		
		/**
		 * Get a tile id by x, y in map
		 * @param p
		 * @return
		 */
		public function getTileId( p:Point ):int
		{
			var row:int = p.y / _tileHeight;
			var col:int = p.x / _tileWidth;
			
			row = MathUtils.clamp(row, 0, _tileSizeH);
			col = MathUtils.clamp(col, 0, _tileSizeW);
			
			return row * _tileSizeW + col;
		}
		// === ！===== Protected or Private Functions ====
		/**
		 * Get all items in the tile
		 * 
		 * @param grid
		 * @return
		 */
		private function getItemsInTile( tile:Dictionary, z_index:Number ):Vector.<ITile>
		{
			var checkZ:Boolean = ( z_index < 0 ); 
			var list:Vector.<ITile> = new Vector.<ITile>();
			for(var ob:* in tile) {
				if(!checkZ || ITile(ob).z == z_index)
					list.push( ob );
			}
			return list;
		}
		private function getItemsInTiles( tiles:Vector.<Dictionary>, z_index:Number ):Vector.<ITile>
		{
			var checkZ:Boolean = ( z_index < 0 ); 
			var list:Vector.<ITile> = new Vector.<ITile>();
			for each( var tile:Dictionary in tiles){
				for(var ob:* in tile){
					if(!checkZ || ITile(ob).z == z_index)
						list.push( ob );	
				}
			}
			return list;
		}
		
	}
}