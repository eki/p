
module P

  class CallExpr < Expr

    def evaluate( environment )
      o = environment.get( String.new( left.value ) )
      o.call( right.list )
    end

  end

end

