
module P

  class String < Object
    attr_reader :value

    def initialize( value='' )
      @value = value.to_s
    end

    def p_send( m, *args )
      case m.to_sym
        when :length then P.number( value.length )

        else super
      end 
    end

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

