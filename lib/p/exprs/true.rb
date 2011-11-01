
module P

  class TrueExpr < Atom

    def evaluate( environment )
      P.true
    end

    def to_s
      "true"
    end

  end

end

