
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

    MATH_OPS.each do |op|
      p_receive( op, "(n)" ) do |env|
        P.number( value.send( op, env.get( 'n' ).value ) )
      end
    end

    p_receive( :'number?' ) { |env| True.new }

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

    p_receive( :'integer?' )  { |env| True.new }
    p_receive( :'rational?' ) { |env| True.new }
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

    p_receive( :'ratio?' )    { |env| True.new }
    p_receive( :'rational?' ) { |env| True.new }
    p_receive( :numerator )   { |env| P.number( numerator ) }
    p_receive( :denominator ) { |env| P.number( denominator ) }
  end

  class Float < Number
    def initialize( value )
      @value = value.to_f
    end

    p_receive( :'float?' )    { |env| True.new }
  end

end

