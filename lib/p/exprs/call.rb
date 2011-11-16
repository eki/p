
module P

  class CallExpr < Expr

    def reduce
      if left.send?
        SendExpr.new( left.left.reduce, left.right.reduce, right )
      else
        self
      end
    end

    def evaluate( environment )
      if left.send?
        reduce.evaluate( environment )
      elsif left.id?
        name = left.to_sym

        if o = environment.local_get( name )
          o.call( right, environment )
        elsif environment.p_self && environment.p_self._get( name )
          environment.p_self.p_send( name, right, environment )
        elsif o = environment.get( name )
          o.call( right, environment )
        else
          P.nil
        end
      else
        o = Expr.nocall( left ).evaluate( environment )
        o.call( right, environment )
      end
    end
  end

end

