
module P

  class NilExpr < Atom

    def evaluate( environment )
      Nil.new
    end

    def to_s
      "nil"
    end

  end

end

