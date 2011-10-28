
module P

  class String < Object
    attr_reader :value

    def initialize( value='' )
      @value = value.to_s
    end

    def initialize_copy( original )
      @value = original.value.dup
    end

    p_receive( :length ) { |env| P.number( value.length ) }

    def ===( o )
      o.kind_of?( String ) ? o.value == value : o.to_s == value
    end

    def to_sym
      r_string.to_sym
    end

    def ==( o )
      o.kind_of?( String ) && o.value == value
    end

    def inspect
      %Q("#{value}")
    end

    def to_s
      value
    end

  end

end

