
module P

  class FalseExpr < Atom

    def evaluate( environment )
      False.new
    end

    def to_s
      "false"
    end

  end

end

