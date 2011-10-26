
module P

  class IdExpr < Atom
    def initialize( value )
      @value = value.respond_to?( :value ) ? value.value : value
    end

    def evaluate( environment )
      o = environment.get( String.new( value ) )
      o.call
    end

    def to_s
      value
    end

    def to_sym
      value.to_sym
    end

  end

end

