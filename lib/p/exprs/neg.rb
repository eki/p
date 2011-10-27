
module P

  class NegExpr < ReducibleExpr
    def reduce
      Expr.sub( NumberExpr::ZERO, list.first )
    end
  end

end

