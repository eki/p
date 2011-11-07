
module P

  class NegExpr < ReducibleExpr
    def reduce
      SendExpr.new( list.first, Expr.id( '-@' ), Expr.args )
    end
  end

end

