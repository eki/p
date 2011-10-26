
module P

  class IdExpr < Atom
    def initialize( value )
      @value = case
        when value.kind_of?( ::String )  then value
        when value.token?                then value.value
        when value.id?                   then value.value
        when value.number?               then value.to_s
      end
    end

    def evaluate( environment )
      if o = environment.get( String.new( value ) )
        o.call
      else
        Nil.new
      end
    end

    def to_s
      value
    end

    def to_sym
      value.to_sym
    end

  end

end

