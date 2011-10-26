
module P

  class ParamsExpr < Expr

    def evaluate( environment )
      list.map { |e| e.evaluate( environment ) }
    end

  end

end

