
module P

  class Number < Object
    attr_reader :n

    def initialize( n )
      @n = Rational( n )
    end

    def p_send( m, *args )
      case m.to_sym
        when :to_s        then String.new( n.to_s )
        when :numerator   then Number.new( @n.numerator )
        when :denominator then Number.new( @n.denominator )
        when :+
          Number.new( n + args.first.to_r )
        when :==
          a = args.first
          Boolean.for( a.kind_of?( Number ) ? n == a.to_r : false )

        else Nil.new
      end 
    end

    def to_s
      n.to_s
    end

    def inspect
      n.inspect
    end

    def to_r
      n
    end


  end

end

