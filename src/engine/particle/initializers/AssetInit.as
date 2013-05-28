package engine.particle.initializers
{
	import engine.managers.AssetsManager;
	import engine.particle.core.Initializer;
	import engine.particle.core.Particle;

	/**
	 * AssetInit
	 * @author hbb
	 */
	public class AssetInit implements Initializer
	{
		// ----------------------------------------------------------------
		// :: Static
		public static var DefaultDomain:String;
		
		// ----------------------------------------------------------------
		// :: Public Members
		[PBInject]
		public var assetsMgr:AssetsManager;
		
		// ----------------------------------------------------------------
		// :: Public Methods
		
		/**
		 * create an asset instance to initialize the particle.view 
		 * by the specified className in AssetsManager
		 * 
		 * @param className, asset class name
		 * @param domain, asset class domain
		 * 
		 */
		public function AssetInit( className:String, domain:String = null )
		{
			_className = className;
			_domain = domain || DefaultDomain;
		}
		
		public function init(p:Particle):void
		{
			var Asset:Class = assetsMgr.getClass( _domain, _className, false );
			p.display = new Asset();
		}
		
		// ----------------------------------------------------------------
		// :: Override Methods
		
		// ----------------------------------------------------------------
		// :: Private Methods
		
		// ----------------------------------------------------------------
		// :: Private Members
		private var _domain:String;
		private var _className:String;
	}
}