
module P

  class FnExpr < Expr

    def evaluate( environment )
      Closure.new( Function.new( left.evaluate, right ), environment )
    end

  end

end

