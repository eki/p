
module P

  class GlobExpr < Expr
    def evaluate( environment )
      Parameter::GLOB
    end
  end

end

