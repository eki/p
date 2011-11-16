
module P

  class HashPairExpr < Expr
    def to_s
      "#{left.inspect} => #{right.inspect}"
    end
  end

end

