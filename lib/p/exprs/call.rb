
module P

  class CallExpr < Expr

    def evaluate( environment )
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
    end

  end

end

