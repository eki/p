
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
      if left.send?
        reduce.evaluate( environment )
      elsif left.seq? || right.seq?
        lvals = left.to_seq.list
        rvals = right.to_seq.list.map { |e| e.evaluate( environment ) }


        # how to identify a destructuring return to a single value?

        if rvals.length == 1
          using_to_list = true
          rvals = rvals.first.r_send( :to_list )
        end

        lvals.zip( rvals ) do |lval, rval|
          rval ||= P.nil
          environment.set( P.string( lval.value ), rval )
        end

        using_to_list ? rvals : P.list( *rvals )
      else
        environment.set( P.string( left.value ), 
          right.evaluate( environment ) )
      end
    end

    def to_s
      "(= #{left} #{right})"
    end
  end

end

