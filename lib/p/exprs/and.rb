
module P

  class AndExpr < Expr
    def evaluate( environment )
      v = left.evaluate( environment )

      if P.true?( v )
        right.evaluate( environment )
      else
        v
      end
    end
  end

end

