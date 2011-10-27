
module P

  class BnotExpr < ReducibleExpr
    def reduce
      SendExpr.new( 
        first.reduce, Expr.id( '~' ), Expr.args )
    end
  end

end

