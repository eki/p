
module P

  class FnExpr < Expr

    def evaluate( environment )
      Closure.new( Function.new( left.list, right ), environment )
    end

  end

end

