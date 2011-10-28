
module P

  class ProgramExpr < Expr
    def reduce
      Expr.program( list.map { |e| e.reduce } )
    end

    def evaluate( environment )
      list.first.evaluate( environment )
    end

  end

end

