
module P

  class WhileExpr < Expr
    def evaluate( environment )
      cond   = list[0]
      b_then = list[1]
      last   = P.nil

      v = cond.evaluate( environment )

      while P.true?( v )
        last = b_then.evaluate( environment )

        v = cond.evaluate( environment )
      end

      last
    end
  end

end

