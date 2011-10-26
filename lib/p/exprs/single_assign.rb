
module P

  class SingleAssignExpr < Expr
    def evaluate( environment )
      environment.bind( String.new( list[0].value ), 
        list[1].evaluate( environment ) )
    end

    def to_s
      "(:= #{left} #{right})"
    end
  end

end

