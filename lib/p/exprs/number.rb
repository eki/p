
module P

  class NumberExpr < Atom

    def evaluate( environment )
      P.number( value.value )
    end

    def to_s
      value.value
    end

  end

end

