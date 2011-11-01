
module P

  class NilExpr < Atom

    def evaluate( environment )
      P.nil
    end

    def to_s
      "nil"
    end

  end

end

