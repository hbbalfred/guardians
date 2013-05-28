package engine.utils
{
	import flash.display.MovieClip;

	public class MovieClipUtils
	{
		/**
		 * all children goto and stop the specific frame
		 *  
		 * @param parent
		 * @param frame
		 */
		public static function gotoAndStopChildren( parent:MovieClip, frame:int ):void
		{
			for (var i:int=0, n:int = parent.numChildren; i < n; ++i)
			{
				var mc:MovieClip = parent.getChildAt(i) as MovieClip;
				if(!mc) continue;
				
				if (mc.totalFrames >= frame) mc.gotoAndStop(frame);
				else mc.gotoAndStop(mc.totalFrames);
				
				gotoAndStopChildren(mc, frame);
			}
		}
		
		/**
		 * find the totalFrames within children 
		 * 
		 * @param parent
		 * @param parentTotalFrames
		 * @return 
		 */
		public static function maxFrames( parent:MovieClip, parentTotalFrames:int ):int
		{
			for (var i:int=0, n:int = parent.numChildren; i < n; ++i)
			{
				var mc:MovieClip = parent.getChildAt(i) as MovieClip;
				if(!mc) continue;
				
				if(parentTotalFrames < mc.totalFrames ) parentTotalFrames = mc.totalFrames; 
				
				maxFrames(mc, parentTotalFrames);
			}
			
			return parentTotalFrames;
		}
	}
}