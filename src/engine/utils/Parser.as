/*
/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
written by
Raphael Graf(r@undefined.ch) 

Feel free to use and modify the classes in this package ndef.parser
Please acknowledge this work in a way.

If you modify the classes in this package ndef.parser
put them into a package different from the original.

14:38 04.05.2008
/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*/
package engine.utils{
	import engine.framework.debug.Logger;

	public class Parser {
		public var success:Boolean;
		public var errormsg:String;
		private var varnames:Array;
		private var expression:String;

		private var pos:uint=0;

		private var tokennumber:Number;
		private var tokenprio:uint=0;
		private var tokenindex:uint=0;
		private var tmpprio:int=0;

		private const funcs1:Array=["sin", "cos", "tan", "asin", "acos", "atan","sqrt", "log", "abs", "ceil", "floor", "round", "random", "fac"];
		private const _funcs1:Array=[_sin, _cos, _tan, _asin, _acos, _atan, _sqrt, _log, _abs, _ceil, _floor, _round, _random, _fac];

		private const funcs2:Array=["min", "max", "pyt"];
		private const _funcs2:Array=[_min, _max, _pyt, _add, _sub, _mult, _div, _mod, _pow];

		private const consts:Array=["E", "PI"];
		private const constvalues:Array=[Math.E, Math.PI];

		private const TNUMBER:uint=0;
		private const TFUNC1:uint=1;
		private const TFUNC2:uint=2;
		private const TVAR:uint=3;

		public function Parser(varnames:Array):void{
			this.varnames=varnames;
		}

		public function parse(expr:String):Array{
			errormsg="";
			success=true;
			var operstack:Array=[];
			var tokenstack:Array=[];
			tmpprio=0;
			var expected:Array=[1,0,1,1,0,0,1];
			var noperators:uint=0;
			expression=expr;
			pos=0;
			while(pos<expression.length){
				if(isOperator()){
					if(isSign() && expected[6]==1){
						var mintoken:Token=new Token(TNUMBER, 0, 0, -1);
						tokenstack.push(mintoken);
						tokenprio=4;
						tokenindex=5;
						noperators+=2;
						addfunc(tokenstack, operstack, TFUNC2);
						expected=[1,0,1,1,0,0,1];
					}
					else if(isComment()){

					}
					else{
						if(expected[1]==0){
							error_parsing(pos, "unexpected operator");
							return [];
						}
						noperators+=2;
						addfunc(tokenstack, operstack, TFUNC2);
						expected=[1,0,1,1,0,0,1];
					}
				}
				else if(isNumber()){
					if(expected[0]==0){
						error_parsing(pos, "unexpected number");
						return [];
					}
					var token:Token=new Token(TNUMBER, 0, 0, tokennumber);
					tokenstack.push(token);
					expected=[0,1,0,0,1,1,0];
				}
				else if(isLeftParenth()){
					if(expected[3]==0){
						error_parsing(pos, "unexpected \"(\"");
						return [];
					}
					expected=[1,0,1,1,0,0,1];
				}
				else if(isRightParenth()){
					if(expected[4]==0){
						error_parsing(pos, "unexpected \")\"");
						return [];
					}
					expected=[0,1,0,0,1,0,0];
				}
				else if(isComma()){
					if(expected[5]==0){
						error_parsing(pos, "unexpected \",\"");
						return [];
					}
					expected=[1,0,0,0,0,0,1];
				}
				else if(isConst()){
					if(expected[0]==0){
						error_parsing(pos, "unexpected constant");
						return [];
					}
					var consttoken:Token=new Token(TNUMBER, 0, 0, tokennumber);
					tokenstack.push(consttoken);
					expected=[0,1,0,0,1,1,0];
				}
				else if(isFunc1()){
					if(expected[3]==0){
						error_parsing(pos, "unexpected function");
						return [];
					}
					addfunc(tokenstack, operstack, TFUNC1);
					noperators++;
					expected=[0,0,0,1,0,0,0];
				}
				else if(isFunc2()){
					if(expected[3]==0){
						error_parsing(pos, "unexpected function");
						return [];
					}
					addfunc(tokenstack, operstack, TFUNC2);
					noperators+=2;
					expected=[0,0,0,1,0,0,0];
				}
				else if(isVar()){
					if(expected[0]==0){
						error_parsing(pos, "unexpected variable");
						return [];
					}
					var vartoken:Token=new Token(TVAR, tokenindex, 0, 0);
					tokenstack.push(vartoken);
					expected=[0,1,0,0,1,1,0];
				}
				else if(isWhite()){
					
				}
				else{
					if(errormsg==""){
						error_parsing(pos, "unknown character");
					}
					else{
						error_parsing(pos, errormsg);
					}
					return [];
				}
				
			}
			if(tmpprio<0 || tmpprio>=10){
				error_parsing(pos, "unmatched \"()\"");
				return [];
			}
			while(operstack.length>0){
				var tmp:Token=operstack.pop();
				tokenstack.push(tmp);
			}
			if(noperators+1 != tokenstack.length){
				error_parsing(pos, "parity");
				return [];
			}
			return tokenstack;
		}
		
		public function simplify(parsedexpression:Array):Array{
			var nstack:Array=[];
			var newexpression:Array=[];
			var n1:Token;
			var n2:Token;
			var f:Function;
			var L:uint=parsedexpression.length;
			var item:Token;
			var i:uint=0;
			for(i=0; i<L; i++){
				item=parsedexpression[i];
				var type_:uint=item.type_;
				if(type_==TNUMBER){
					nstack.push(item);
				}
				else{
					if(type_==TFUNC2 && nstack.length>1){
						n2=nstack.pop();
						n1=nstack.pop();
						f =_funcs2[item.index_];
						item=new Token(TNUMBER, 0, 0, f(n1.number_, n2.number_));
						nstack.push(item);
					}
					else if(type_==TFUNC1 && nstack.length>0){
						n1=nstack.pop();
						f =_funcs1[item.index_];
						item=new Token(TNUMBER, 0, 0, f(n1.number_));
						nstack.push(item);
					}
					else{
						while(nstack.length>0){
							newexpression.push(nstack.shift());
						}
						newexpression.push(item);
					}
				}
			}
			while(nstack.length>0){
				newexpression.push(nstack.shift());
			}
			return newexpression;
		}
		
		public function eval(pexpression:Array, values:Array):Number {
			var nstack:Array=[];
			var n1:Number;
			var n2:Number;
			var f:Function;
			var L:uint=pexpression.length;
			var item:Token;
			var i:uint=0;
			for(i=0; i<L; i++){
				item=pexpression[i];
				var type_:uint=item.type_;
				if(type_==TNUMBER){
					nstack.push(item.number_);
				}
				else if(type_==TFUNC2){
					n2=nstack.pop();
					n1=nstack.pop();
					f =_funcs2[item.index_];
					nstack.push(f(n1, n2));
				}
				else if(type_==TVAR){
					nstack.push(values[item.index_]);
				}
				else if(type_==TFUNC1){
					n1=nstack.pop();
					f =_funcs1[item.index_];
					nstack.push(f(n1));
				}
			}
			return nstack[0];
		}

		private function addfunc(tokenstack:Array, operstack:Array, type_:uint):void{
			var operator:Token=new Token(type_, tokenindex, tokenprio+tmpprio, 0);
			while(operstack.length>0){
				if(operator.prio_ <= operstack[operstack.length-1].prio_){
					tokenstack.push(operstack.pop()); 
				}
				else{
					break;
				}
			}
			operstack.push(operator);
		}

		private function error_parsing(column:uint, msg:String):void{
			success=false;
			errormsg="parse error [column "+(column)+"]: "+msg;
			Logger.error( this, "error_parsing", errormsg);
		}

//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		private function isNumber():Boolean{
			var r:Boolean=false;
			var str:String="";
			while(pos<expression.length){
				var code:uint=expression.charCodeAt(pos);
				if((code>= 48 && code<=57) || code==46){
					str+=expression.charAt(pos);
					pos++;
					tokennumber=parseFloat(str);
					r=true;
				}
				else{
					break;
				}
			}
			return r;
		}

		private function isConst():Boolean{
			var str:String;
			for(var i:uint=0; i<consts.length; i++){
				str=expression.substr(pos, consts[i].length);
				if(consts[i]==str){
					tokennumber=constvalues[i];
					pos+=str.length;
					return true;
				}
			}
			return false;
		}

		private function isOperator():Boolean{
			var code:uint=expression.charCodeAt(pos);
			if(code==43){ // +
				tokenprio=0;
				tokenindex=3;
			}
			else if(code==45){ // -
				tokenprio=0;
				tokenindex=4;
			}
			else if(code==42){ // *
				tokenprio=1;
				tokenindex=5;
			}
			else if(code==47){ // /
				tokenprio=2;
				tokenindex=6;
			}
			else if(code==37){// %
				tokenprio=2;
				tokenindex=7;
			}
			else if(code==94){ // ^
				tokenprio=3;
				tokenindex=8;
			}
			else{
				return false;
			}
			pos++;
			return true;
		}

		private function isSign():Boolean{
			var code:uint=expression.charCodeAt(pos-1);
			if(code==45){ // -
				return true;
			}
			return false;
		}

		private function isLeftParenth():Boolean{
			var code:uint=expression.charCodeAt(pos);
			if(code==40){ // (
				pos++;
				tmpprio+=10;
				return true;
			}
			return false;
		}

		private function isRightParenth():Boolean{
			var code:uint=expression.charCodeAt(pos);
			if(code==41){ // )
				pos++;
				tmpprio-=10;
				return true;
			}
			return false;
		}

		private function isComma():Boolean{
			var code:uint=expression.charCodeAt(pos);
			if(code==44){ // ,
				pos++;
				return true;
			}
			return false;
		}
		private function isWhite():Boolean{
			var code:uint=expression.charCodeAt(pos);
			if(code==32){ // ,
				pos++;
				return true;
			}
			return false;
		}

		private function isFunc1():Boolean{
			var str:String;
			for(var i:uint=0; i<funcs1.length; i++){
				var L:uint=funcs1[i].length;
				str=expression.substr(pos, L);
				if(funcs1[i]==str){
					tokenindex=i;
					tokenprio=5;
					pos+=L;
					return true;
				}
			}
			return false;
		}

		private function isFunc2():Boolean{
			var str:String;
			for(var i:uint=0; i<funcs2.length; i++){
				var L:uint=funcs2[i].length;
				str=expression.substr(pos, L);
				if(funcs2[i]==str){
					tokenindex=i;
					tokenprio=5;
					pos+=L;
					return true;
				}
			}
			return false;
		}

		private function isVar():Boolean{
			var str:String="";
			for(var i:uint=0; i<varnames.length; i++){
				str=expression.substr(pos, varnames[i].length);
				if(varnames[i]==str){
					tokenindex=i;
					tokenprio=4;
					pos+=str.length;
					return true;
				}
			}
			return false;
		}

		private function isComment():Boolean{
			var code:uint=expression.charCodeAt(pos-1);
			if (code==47 && expression.charCodeAt(pos)==42) {
				pos=expression.indexOf("*/", pos)+2;
				if (pos==1) {
					pos=expression.length;
				}
				return true;
			}
			return false;
		}

//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		private function _add(a:Number, b:Number):Number{
			return a+b;
		}
		private function _sub(a:Number, b:Number):Number{
			return a-b;
		}
		private function _mult(a:Number, b:Number):Number{
			return a*b;
		}
		private function _div(a:Number, b:Number):Number{
			return a/b;
		}
		private function _mod(a:Number, b:Number):Number{
			return a%b;
		}
		private function _pow(a:Number, b:Number):Number{
			return Math.pow(a, b);
		}

		private function _sin(a:Number):Number{
			return Math.sin(a);
		}
		private function _cos(a:Number):Number{
			return Math.cos(a);
		}
		private function _tan(a:Number):Number{
			return Math.tan(a);
		}
		private function _asin(a:Number):Number{
			return Math.asin(a);
		}
		private function _acos(a:Number):Number{
			return Math.acos(a);
		}
		private function _atan(a:Number):Number{
			return Math.atan(a);
		}
		private function _sqrt(a:Number):Number{
			return Math.sqrt(a);
		}
		private function _log(a:Number):Number{
			return Math.log(a);
		}
		private function _abs(a:Number):Number{
			return Math.abs(a);
		}
		private function _ceil(a:Number):Number{
			return Math.ceil(a);
		}
		private function _floor(a:Number):Number{
			return Math.floor(a);
		}
		private function _round(a:Number):Number{
			return Math.round(a);
		}
		private function _random(a:Number):Number{
			return Math.random()*a;
		}
		private function _fac(a:Number):Number{ //a! 
			a=Math.floor(a);
			var b:Number=a;
			while(a>1){
				b=b*(--a);
			}
			return b;
		}

		private function _min(a:Number, b:Number):Number{
			return Math.min(a, b);
		}
		private function _max(a:Number, b:Number):Number{
			return Math.max(a, b);
		}
		private function _pyt(a:Number, b:Number):Number{
			return Math.sqrt(a*a + b*b);
		}
	}
}
