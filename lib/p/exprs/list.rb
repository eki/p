
module P

  class ListExpr < Atom

    def initialize( value=[] )
      @value = value
    end

    def evaluate( environment )
      P.list( *value.map { |expr| expr.evaluate( environment ) } )
    end

    def to_s
      value.to_s
    end

    def inspect
      to_s
    end

  end

end

