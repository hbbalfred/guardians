package engine.ui.fx
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * BlazeFX
	 * 
	 * 
	 * // for static sprite
	 * var blaze:BlazeFX = new BlazeFX( canvas, enoughWidth, enoughHeight );
	 * blaze.emitter = drawEmitter();
	 * onTick{
	 *    blaze.update();
	 * }
	 * 
	 * // for dynamic movie clip
	 * var blaze:BlazeFX = new BlazeFX( canvas, enoughWidth, enoughHeight );
	 * onTick{
	 *    blaze.emitter = drawEmitter();
	 *    blaze.update(); 
	 * }
	 * 
	 * @author hbb
	 */
	public class BlazeFX
	{
		// ----------------------------------------------------------------
		// :: Static
		public static const TYPE_RED:String = "red";
		public static const TYPE_BLUE:String = "blue";
		public static const TYPE_ONI:String = "oni";
		public static const TYPE_CHAOS:String = "chaos";
		public static const TYPE_EARTH:String = "earth";
		public static const TYPESMAP:Array = [ TYPE_RED, TYPE_BLUE, TYPE_ONI, TYPE_CHAOS, TYPE_EARTH ];
		
		[Embed(source="fire-color.png", mimeType="image/png")]
		protected static const FireColor:Class;
		
		protected static const fireColor:Bitmap = new FireColor;
		protected static const zeroArray:Array = createZeroArray();
		protected static const spread:ConvolutionFilter = new ConvolutionFilter(3,3, [0,1,0,1,1,1,0,1,0], 5);
		protected static const zero:Point = new Point(0,0);
		protected static const white:ColorTransform = new ColorTransform(0,0,0,1, 255,255,255,0);
		
		private static function createZeroArray():Array
		{
			var a:Array = [];
			for(var i:int = 0; i < 256; ++i)
				a[i] = 0;
			return a;
		}
		
		private static function createColorMatrix( a:Number ):ColorMatrixFilter
		{
			return new ColorMatrixFilter([
				a, 0, 0, 0, 0,
				0, a, 0, 0, 0,
				0, 0, a, 0, 0,
				0, 0, 0, 1, 0,
			]);
		}
		
		private static function createPalette( row:int ):Array
		{
			var a:Array = [];
			for (var i:int = 0; i < 256; i++)
			{
				var c:uint = fireColor.bitmapData.getPixel32(i, row * 32);
				//				var r:uint = (c >> 16) & 0xff;
				//				var g:uint = (c >> 8) & 0xff;
				//				var b:uint = c & 0xff;
				//				var a:uint = Math.max(r,g,b);
				//				c = (a << 24) | (r << 16) | (g << 8 ) | b;
				a[i] = c;
			}
			return a;
		}
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		public function get canvas():*{ return _canvas; }
		
		public function get drawOffsetY():Number{ return _drawOffset.ty; }
		
		public function set emitter( v:IBitmapDrawable ):void
		{
			_emitter = v ;
			if( !_emitter ) _emitter = new Shape;
		}
		
		public function get fireType():String{ return _fireType; }
		public function set fireType( v:String ):void
		{
			_fireType = v;
			var i:int = TYPESMAP.indexOf(v);
			if( i == -1 )
				i = 5;
			_palette = createPalette( i );
		}
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * BlazeFX constructor
		 *  
		 * @param canvas, an object that contains the bitmapData property, such as Bitmap or BitmapRenderer
		 * @param w, canvas width
		 * @param h, canvas height
		 * @param type, blaze type
		 * @param drawOffsetY, offset the emitter drawing
		 * 
		 */
		public function BlazeFX( canvas:*, w:Number, h:Number, type:String = TYPE_RED, drawOffsetY:Number = 0 )
		{
			this.fireType = type;
			
			_canvas = canvas;
			_drawOffset.ty = drawOffsetY;
			
			_grey = new BitmapData( w, h + drawOffsetY, true, 0 );
			_output = _grey.clone();
			_cooling = new BitmapData( w, h + drawOffsetY, false, 0 );
			
			if( "bitmapData" in _canvas )
				_canvas.bitmapData = _output;
			else
				throw new ArgumentError("Error: no bitmapData in canvas");
		}
		
		public function destroy():void
		{
			if(_grey) _grey.dispose();
			if(_output) _output.dispose();
			if(_cooling) _cooling.dispose();
			
			_grey = null;
			_output = null;
			_cooling = null;
		}
		
		public function update():void
		{
			// draw fire fx
			const rect:Rectangle = _grey.rect;
			const octaves:int = _offsets.length;
			
			_grey.draw(_emitter, _drawOffset, white);
			_grey.applyFilter(_grey, rect, zero, spread);
			_cooling.perlinNoise(8, 8, octaves, _randSeed, false,false,0,true, _offsets);
			_offsets[0].x += 1;
			_offsets[1].y += 1;
			_cooling.applyFilter(_cooling, rect, zero, _colorMat);
			_grey.draw(_cooling, null, null, BlendMode.SUBTRACT);
			_grey.scroll(0,-2);
			_output.paletteMap(_grey, rect, zero, _palette, zeroArray, zeroArray, zeroArray);
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		protected var _fireType:String;
		
		protected var _drawOffset:Matrix = new Matrix;
		protected var _noiseScale:Number = 8;
		protected var _randSeed:int = Math.random() * 2012;
		protected var _colorMat:ColorMatrixFilter = createColorMatrix( 0.5 );
		protected var _emitter:IBitmapDrawable;
		protected var _palette:Array;
		protected var _grey:BitmapData;
		protected var _cooling:BitmapData;
		protected var _output:BitmapData;
		protected var _offsets:Array = [new Point, new Point];
		protected var _canvas:*;
		
	}
}