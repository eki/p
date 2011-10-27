
module P

  class CifExpr < ReducibleExpr
    def reduce
      Expr.if( right, Expr.block( left ) )
    end
  end

end

