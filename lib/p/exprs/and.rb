
module P

  class AndExpr < Expr
    def evaluate( environment )
      v = left.evaluate( environment )

      if Boolean.true?( v )
        right.evaluate( environment )
      else
        v
      end
    end
  end

end

