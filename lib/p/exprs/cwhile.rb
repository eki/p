
module P

  class CwhileExpr < ReducibleExpr
    def reduce
      Expr.while( right, Expr.block( left ) )
    end
  end

end

