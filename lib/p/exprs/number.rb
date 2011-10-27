
module P

  class NumberExpr < Atom

    def evaluate( environment )
      P.number( value.value )
    end

    def to_s
      value.value
    end

    ZERO = NumberExpr.new( Token.new( :number, 0, 0, 0 ) )

  end

end

