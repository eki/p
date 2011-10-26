
module P

  class NeqExpr < ReducibleExpr
    def reduce
      Expr.not( Expr.eq( left.reduce, right.reduce ) )
    end

    def to_s
      "(!= #{left} #{right})"
    end
  end

end

