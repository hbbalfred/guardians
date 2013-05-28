package engine.appHelper
{
	public class Configuration
	{	
		public function get VERSION():String {
			return "dev";
		}
		public function get FRAME_RATE():Number{
			return 32;
		}
		
		public function get APP_WIDTH():Number { return 756; }
		public function get APP_HEIGHT():Number { return 640; }
	}
}