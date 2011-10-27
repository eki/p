
module P

  class OrExpr < Expr
    def evaluate( environment )
      v = left.evaluate( environment )

      if Boolean.true?( v )
        v
      else
        right.evaluate( environment )
      end
    end
  end

end

