
module P

  class FnExpr < Expr
    attr_accessor :source, :parameters_source

    def evaluate( environment )
      fn = Function.new( left.evaluate, right, source, parameters_source )
      Closure.new( fn, environment )
    end

  end

end

