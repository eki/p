
module P

  class ProgramExpr < Expr

    def evaluate( environment )
      list.first.evaluate( environment )
    end

  end

end

