
module P

  class BlockExpr < Expr
    def reduce
      Expr.block( list.map { |e| e.reduce } )
    end

    def evaluate( environment )
      list.inject( P.nil ) { |m,n| n.evaluate( environment ) }
    end

  end

end

