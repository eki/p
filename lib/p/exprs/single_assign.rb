
module P

  class SingleAssignExpr < Expr
    def evaluate( environment )
      if left.seq? || right.seq?
        lvals = left.to_seq.list
        rvals = right.to_seq.list.map { |e| e.evaluate( environment ) }

        lvals.zip( rvals ) do |lval, rval|
          rval ||= Nil.new
          environment.bind( String.new( lval.value ), rval )
        end

        List.new( *rvals )
      else
        environment.bind( String.new( left.value ), 
          right.evaluate( environment ) )
      end
    end

    def to_s
      "(:= #{left} #{right})"
    end
  end

end

