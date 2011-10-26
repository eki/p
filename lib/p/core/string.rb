
module P

  class String < Object
    attr_reader :r_string

    def initialize( r_string='' )
      @r_string = r_string
    end

    def p_send( m, *args )
      case m.to_sym
        when :length then Number.new( @r_string.length )

        else Nil.new
      end 
    end

    def ===( o )
      o.kind_of?( P::String ) ? o.r_string == r_string : o.to_s == r_string
    end

    def to_sym
      r_string.to_sym
    end

    def ==( o )
      o.r_string == r_string
    end

    def inspect
      %Q("#{r_string}")
    end

    def to_s
      inspect
    end

  end

end

