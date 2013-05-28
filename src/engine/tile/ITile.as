package engine.tile
{
	import flash.geom.Point;

	/**
	 * Interface of spatial 2D object
	 * @author Tang Bo Hao
	 */
	public interface ITile
	{
		// Position
		function set tileid(v:int):void;
		function get tileid():int;
		function get position():Point;
		// Z-Index
		function get z():Number;
		// Item Notification
		function itemAddedToTile(item: ITile):void;
		function itemRemovedFromTile(item: ITile):void;
	}
}