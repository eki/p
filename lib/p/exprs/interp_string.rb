
module P

  class InterpStringExpr < Expr

    def evaluate( environment )
      s = list.inject( '' ) { |m,n| m + n.evaluate( environment ).to_s }
      P.string( s )
    end

  end

end

