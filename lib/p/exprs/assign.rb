
module P

  class AssignExpr < Expr
    def evaluate( environment )
      environment.set( String.new( list[0].value ), 
        list[1].evaluate( environment ) )
    end

    def to_s
      "(= #{left} #{right})"
    end
  end

end

