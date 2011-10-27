
module P

  class IfExpr < Expr
    def evaluate( environment )
      cond   = list[0]
      b_then = list[1]
      b_else = list[2]

      v = cond.evaluate( environment )

      if Boolean.true?( v )
        b_then.evaluate( environment )
      elsif b_else
        b_else.evaluate( environment )
      else
        Nil.new
      end
    end
  end

end

