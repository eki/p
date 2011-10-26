
module P

  class NotExpr < Expr
    def evaluate( environment )
      v = first.evaluate( environment )

      if v == Nil.new || v == False.new
        True.new
      else
        False.new
      end
    end

    def to_s
      "(! #{first})"
    end
  end

end

