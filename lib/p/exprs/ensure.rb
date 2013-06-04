
module P

  class EnsureExpr < Expr
    def evaluate( environment )
      first.evaluate( environment )
    end
  end

end

