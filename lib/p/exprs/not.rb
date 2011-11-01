
module P

  class NotExpr < Expr
    def evaluate( environment )
      if P.true?( first.evaluate( environment ) )
        P.false
      else
        P.true
      end
    end

    def to_s
      "(! #{first})"
    end
  end

end

