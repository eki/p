
module P

  class CunExpr < ReducibleExpr
    def reduce
      Expr.if( Expr.not( right ), left )
    end
  end

end

