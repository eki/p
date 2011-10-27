
module P

  class WhileExpr < Expr
    def evaluate( environment )
      cond   = list[0]
      b_then = list[1]
      last   = Nil.new

      v = cond.evaluate( environment )

      while Boolean.true?( v )
        last = b_then.evaluate( environment )

        v = cond.evaluate( environment )
      end

      last
    end
  end

end

