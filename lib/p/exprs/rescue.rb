
module P

  class RescueExpr < Expr
    def evaluate( environment, error )
      environment.bind( P.string( first.value ), error )

      last.evaluate( environment )
    end
  end

end

