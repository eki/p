
module P

  class AssignExpr < Expr
    def reduce
      if left.send?
        SendExpr.new( left.list[0].reduce, Expr.id( "#{left.list[1]}=" ), 
          Expr.args( right.reduce ) )
      else
        self
      end
    end

    def evaluate( environment )
      if left.seq? || right.seq?
        lvals = left.to_seq.list
        rvals = right.to_seq.list.map { |e| e.evaluate( environment ) }

        lvals.zip( rvals ) do |lval, rval|
          rval ||= Nil.new
          environment.set( String.new( lval.value ), rval )
        end

        List.new( *rvals )
      else
        environment.set( String.new( left.value ), 
          right.evaluate( environment ) )
      end
    end

    def to_s
      "(= #{left} #{right})"
    end
  end

end

