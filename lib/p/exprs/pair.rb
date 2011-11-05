
module P

  class PairExpr < Expr
    def to_s
      "#{left.inspect}: #{right.inspect}"
    end
  end

end

