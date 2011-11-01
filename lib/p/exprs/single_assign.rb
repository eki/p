
module P

  class SingleAssignExpr < Expr
    def evaluate( environment )
      if left.seq? || right.seq?
        lvals = left.to_seq.list
        rvals = right.to_seq.list.map { |e| e.evaluate( environment ) }

        # how to identify a destructuring return to a single value?

        if rvals.length == 1
          using_to_list = true
          rvals = rvals.first.r_send( :to_list )
        end

        lvals.zip( rvals ) do |lval, rval|
          rval ||= P.nil
          environment.bind( lval.value.to_sym, rval )
        end

        using_to_list ? rvals : P.list( *rvals )
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

