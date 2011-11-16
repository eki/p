
module P

  class ReturnException < StandardError
    attr_reader :value

    def initialize( value )
      @value = value
    end
  end

  class ReturnExpr < Expr
    def evaluate( environment )
      raise ReturnException.new( first.evaluate( environment ) )
    end
  end

end

