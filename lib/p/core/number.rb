
module P

  class Number
    attr_reader :n

    def initialize( n )
      @n = Rational( n )
    end

    def p_send( m, *args )
      case m
        when :to_s        then String.new( n.to_s )
        when :numerator   then Number.new( @n.numerator )
        when :denominator then Number.new( @n.denominator )

        else Nil.new
      end 
    end

    def to_s
      n.to_s
    end

    def inspect
      n.inspect
    end


  end

end

