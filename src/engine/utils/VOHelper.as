package engine.utils
{
	import engine.framework.util.TypeUtility;

	/**
	 * VO Parser
	 * @author Gui Lin
	 */
	public class VOHelper
	{

		private static var _context:Object;
		private static var _exprCache:Object;
		
		/**
		 * Set updateVO or doExpr Context
		 * @param context
		 */
		public static function resetContext(context:Object):void {
			_context = context;
		}
		
		/**
		 * Parse Expr String
		 * @param code
		 * @param rest
		 * @return 
		 */
		public static function doExpr(code:String, ...rest):* {
			code = replaceStrByVO( code, _context );
			code = code.replace(/^\s+/, '').replace(/\s+$/, '');
			if(code.match(/^\d+$/)) {
				return parseInt(code);
			} else if (code.match(/^\d*\.\d+$/)) {
				return parseFloat(code);
			} else {
				var m:Array = code.match(/^['"](.*)['"]$/);
				if(m) {
					return m[1];
				}
			}
			
			var parser:Parser = new Parser([]);
			var arr:Array = parser.parse(code);
			return parser.eval(arr, []);
		}

		/**
		 * Parse Expr String in a VO
		 * @param vo
		 */
		public static function updateVO(vo:*):void
		{
			var list:Array = TypeUtility.getListOfPublicFields(vo);
			var len:int = list.length;
			for(var i:int = 0; i < len; ++i)
			{
				var name:String = list[i];
				
				var re:RegExp = /(.*)Expr$/;
				var match:Array = name.match(re);
				if(!match) continue;
				var code:String = vo[name];
				if(!code) continue;
				
				vo[match[1]] = doExpr(code);
				
			}
		}
		
		/**
		 * Replace all "{key}" with vo["key"] in the String
		 * @param str
		 * @param vo
		 * @return 
		 */
		public static function replaceStrByVO( str:String, vo:* ):String{
			var ret:String = str;
			
//			while( true ){
//				var fields:Array = TypeUtility.getListOfPublicFields( vo );
//				fields.forEach( function( name:String, ...rest):void{
//					ret = StringUtils.replaceString(ret, '{' + name + '}', vo[name]);
//				});
//				
//				var reg:RegExp = /\{(.*)\}/g;
//				var mat:Array = reg.exec( ret );
//				if( !mat || mat.length < 2 || vo[mat[1]] == null){
//					break;
//				}
//			}
			
			var reg:RegExp = /\{(\w*)\}/g;
			var mat:Array = str.match( reg );
			
			while( mat && mat.length > 0 ){
				var nofound:Boolean = true;
				for each( var key:String in mat ){
					var name:String = key.substring(1, key.length -1 );
					if( Object(vo).hasOwnProperty( name ) ){
						nofound = false;
						ret = StringUtils.replaceString(ret, key, vo[name]);
					}
				}
				if( nofound ){
					break;
				}else{
					mat = ret.match( reg );
				}
			}
			
			return ret;
		}
	}
}