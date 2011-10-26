
module P

  def self.number( value )
    case value
      when ::Integer  then Integer.new( value )
      when ::Rational then P.number( Ratio.new( value ) )
      when ::Float    then Float.new( value )
      when ::String   then P.number( Ratio.new( value ) )
      when Ratio
        if value.denominator == 1
          P.number( value.numerator )
        else
          value
        end
    end
  end

  class Number < Object
    attr_reader :value

    def initialize( n )
      @n = Rational( n )
    end

    MATH_OPS = [:+, :-, :*, :/, :%]

    def p_send( m, *args )
      if MATH_OPS.include?( m )
        return P.number( value.send( m, args.first.value ) )
      end

      case m.to_sym
        when :'number?'  then True.new

        else super
      end
    end

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end

    def ==( o )
      o.kind_of?( Number ) && value == o.value
    end
  end

  class Integer < Number
    def initialize( value )
      @value = value.to_i
    end

    def p_send( m, *args )
      case m.to_sym
        when :'integer?'   then True.new
        when :'rational?'  then True.new

        else super
      end
    end
  end

  class Ratio < Number
    def initialize( value )
      @value = Rational( value )
    end

    def numerator
      value.numerator
    end

    def denominator
      value.denominator
    end

    def p_send( m, *args )
      case m.to_sym
        when :'ratio?'     then True.new
        when :'rational?'  then True.new
        when :numerator    then P.number( numerator )
        when :denominator  then P.number( denominator )

        else super
      end
    end
  end

  class Float < Number
    def initialize( value )
      @value = value.to_f
    end

    def p_send( m, *args )
      case m.to_sym
        when :'float?'  then True.new

        else super
      end
    end
  end

end

