
module P

  class SingleAssignExpr < Expr
    def evaluate( environment )
      if left.seq? || right.seq?
        lvals = left.to_seq.list
        rvals = right.to_seq.list.map { |e| e.evaluate( environment ) }

        lvals.zip( rvals ) do |lval, rval|
          rval ||= P.nil
          environment.bind( lval.value.to_sym, rval )
        end

        P.list( *rvals )
      else
        environment.bind( left.value.to_sym, 
          right.evaluate( environment ) )
      end
    end

    def to_s
      "(:= #{left} #{right})"
    end
  end

end

