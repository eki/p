
module P

  class InterpStringExpr < Expr

    def evaluate( environment )
      s = list.inject( '' ) { |m,n| m + n.evaluate( environment ).to_s }
      String.new( s )
    end

  end

end

