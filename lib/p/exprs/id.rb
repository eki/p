
module P

  class IdExpr < Atom
    def initialize( value )
      @value = case
        when value.kind_of?( ::String )  then value
        when value.token?                then value.value
        when value.id?                   then value.value
        when value.number?               then value.to_s
        when value.glob?                 then :*
      end
    end

    def evaluate( environment )
      name = to_sym

      if o = environment.local_get( name )
        o.call( Expr.args, environment )
      elsif environment.p_self && environment.p_self._get( name )
        environment.p_self.p_send( name, Expr.args, environment )
      elsif o = environment.get( name )
        o.call( Expr.args, environment )
      else
        P.nil
      end
    end

    def to_s
      value
    end

    def to_sym
      value.to_sym
    end

    def to_p
      value.to_p
    end

  end

end

