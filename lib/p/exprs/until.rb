
module P

  class UntilExpr < ReducibleExpr
    def reduce
      Expr.while( Expr.not( left ), right )
    end
  end

end

