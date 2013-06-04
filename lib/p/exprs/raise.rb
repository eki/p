
module P

  class RaiseException < StandardError
    attr_reader :value

    def initialize( value )
      @value = value
    end
  end

  class RaiseExpr < Expr
    def evaluate( environment )
      raise RaiseException.new( first.evaluate( environment ) )
    end
  end

end

