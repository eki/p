
module P

  class FalseExpr < Atom

    def evaluate( environment )
      P.false
    end

    def to_s
      "false"
    end

  end

end

