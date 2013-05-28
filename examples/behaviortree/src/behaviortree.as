package
{
	import flash.display.Sprite;
	
	import test.Test1;
	
	/**
	 * behaviortree
	 * @author hbb
	 */
	public class behaviortree extends Sprite
	{
		// ----------------------------------------------------------------
		// :: Static
		
		// ----------------------------------------------------------------
		// :: Public Members
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		public function behaviortree()
		{
			this.addChild( new Test1 );
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
	}
}