
module P

  class BlockExpr < Expr

    def evaluate( environment )
      list.inject( Nil.new ) { |m,n| n.evaluate( environment ) }
    end

  end

end

