package engine.utils{
	internal class Token{
		internal var type_:uint;
		internal var index_:uint;
		internal var prio_:int;
		internal var number_:Number;
		public function Token(type_:uint, index_:uint=0, prio_:int=0, number_:Number=0):void{
			this.type_=type_;
			this.index_=index_;
			this.prio_=prio_;
			this.number_=number_;
		}
	}
}
