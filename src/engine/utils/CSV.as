/**
 *   This file is a part of csvlib, written by Marco Müller / http://short-bmc.com
 *
 *   The csvlib is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

package engine.utils
{
	
	// 1 line split comma, but need extra code to handle \", \'
	// var components : Array = line.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/g);
	
	
	/**
	 *   TODO Package description ...
	 *
	 *   @author Marco Müller / http://shorty-bmc.com
	 *   @see http://rfc.net/rfc4180.html RFC4180
	 *    @see http://csvlib.googlecode.com csvlib
	 *   @langversion ActionScript 3.0
	 *   @tiptext
	 */
	public class CSV
	{
		
		
		private var fieldSeperator    : String
		private var fieldEnclosureToken : String
		private var recordsetDelimiter  : String
		
		/**
		 *   TODO Constructor description ...
		 *
		 *   @param request URLRequest
		 *   @langversion ActionScript 3.0
		 *   @tiptext
		 */
		public function CSV()
		{
			fieldSeperator     = ','
			fieldEnclosureToken = '"'
			recordsetDelimiter   = '\r'
		}
		
		
		/**
		 *   TODO Public method description ...
		 *
		 *   @param raw The sting to decode
		 *   @param event Never set this, its only for internal use
		 *   @langversion ActionScript 3.0
		 *   @tiptext
		 */
		public function decode( text:String ) : Array
		{
			var count  : int = 0
			var result : Array = new Array ()
			var data:Array = text.split( recordsetDelimiter );
			for(  var i : int = 0; i < data.length; i++ )
			{
				if( !Boolean( count % 2 ) )
					result.push( data[ i ] )
				else
					result[ result.length - 1 ] += data[ i ]
				count += _count( data[ i ] , fieldEnclosureToken )
			}
			result = result.filter( isNotEmptyRecord )
			result.forEach( fieldDetection )
			return result
		}
		
		
		
		/**
		 *
		 *   @langversion ActionScript 3.0
		 *   @tiptext
		 */
		public function encode (data:Array) : String
		{
			var result : String = ''
			if ( data && data.length > 0 )
				for each ( var recordset : Array in data )
				result += recordset.join( fieldSeperator ) + recordsetDelimiter
			return result
		}
		
		public static function parseRow(data:Array, fields):Object
		{
			var row = {};
			for(var col=0;col<fields.length;col++){
				row[fields[col]]=data[col];						
			}
			return row;
		}
		
		/**
		 * first line is fields
		 */
		public static function parseTable(data:Array) : Array
		{
			var len = data.length;
			var fields = data[0];
			var result:Array = [];
			if(len > 0 ){
				for(var i=1; i<len; i++){
					result.push(parseRow(data[i], fields));
				}
			}
			return result;
		}
		
		/**
		 *  first line is fields, first column is key field
		 */
		public static function parse2D(data:Array) : Object
		{
			var len = data.length;
			var fields = data[0];
			var result = {};
			if(len>0){
				for(var i=1;i<len;i++){
					var row = data[i];
					result[row[0]] = parseRow(row, fields);
				}
			}
			return result;
		}
		
		// -> private methods
		
		/**
		 *   TODO Private method description ...
		 *
		 *   @param element *
		 *   @param index int
		 *   @param arr Array
		 *   @return Boolean true if recordset has values, false if not
		 *   @langversion ActionScript 3.0
		 *   @tiptext
		 */
		private function fieldDetection( element : *, index : int, arr : Array ) : void
		{
			var count  : uint  = 0;
			var result : Array = new Array ();
			var tmp    : Array = element.split( fieldSeperator );
			for( var i : uint = 0; i < tmp.length; i++ )
			{
				if( !Boolean( count % 2 ) )
					result.push( StringUtils.trimSpace( tmp[ i ] ) );
				else
					result[ result.length - 1 ] += fieldSeperator + tmp[ i ];
				count += _count( tmp[ i ] , fieldEnclosureToken );
			}
			arr[ index ] = result
		}
		
		
		
		/**
		 *   TODO Private method description ...
		 *
		 *   @param element *
		 *   @param index int
		 *   @param arr Array
		 *   @return Boolean true if recordset has values, false if not
		 *   @langversion ActionScript 3.0
		 *   @tiptext
		 */
		private function isNotEmptyRecord( element : *, index : int, arr : Array ) : Boolean
		{
			return Boolean( StringUtils.trimSpace( element ) );
		}
		
		
		private static function _count ( haystack : String, needle : String, offset : Number = 0, length : Number = 0 ) : Number
		{
			if ( length === 0 )
				length = haystack.length
			var result : Number = 0;
			haystack = haystack.slice( offset, length );
			while ( haystack.length > 0 && haystack.indexOf( needle ) != -1 )
			{
				haystack = haystack.slice( ( haystack.indexOf( needle ) + needle.length ) );
				result++;
			}
			return result;
		}
		
	}
	
}
