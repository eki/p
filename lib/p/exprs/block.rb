
module P

  class BlockExpr < Expr
    def reduce
      Expr.block( list.map { |e| e.reduce } )
    end

    def evaluate( environment )
      list.inject( Nil.new ) { |m,n| n.evaluate( environment ) }
    end

  end

end

