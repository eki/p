
module P

  class TrueExpr < Atom

    def evaluate( environment )
      True.new
    end

    def to_s
      "true"
    end

  end

end

