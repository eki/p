
module P

  class CuntilExpr < ReducibleExpr
    def reduce
      Expr.while( Expr.not( right ), left )
    end
  end

end

