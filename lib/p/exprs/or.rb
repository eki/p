
module P

  class OrExpr < Expr
    def evaluate( environment )
      v = left.evaluate( environment )

      if P.true?( v )
        v
      else
        right.evaluate( environment )
      end
    end
  end

end

