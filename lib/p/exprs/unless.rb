
module P

  class UnlessExpr < ReducibleExpr
    def reduce
      Expr.if( Expr.not( left ), right )
    end
  end

end

