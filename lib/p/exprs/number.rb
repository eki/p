
module P

  class NumberExpr < Atom

    def evaluate( environment )
      Number.new( value.value )
    end

    def to_s
      value.value
    end

  end

end

