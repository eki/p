
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

    OPS = [:+, :-, :*, :/, :%, :<=>, :**, :<, :>, :<=, :>=]

    OPS.each do |op|
      receive( op, 'n' ) do |env|
        value.send( op, env[:n].value )  #  coerce ? to_number ?
      end
    end

    receive( :-@ ) { |env| self.class.new( -value ) }

    receive( :number?, %q( () -> true ) )

    receive( :to_float    ) { |env| Float.new( value ) }
    receive( :to_integer  ) { |env| Integer.new( value ) }
    receive( :to_ratio    ) { |env| Ratio.new( value ) }
    receive( :to_rational ) { |env| P.number( Ratio.new( value ) ) }

    receive( :to_literal  ) { |env| to_s }
    receive( :to_string   ) { |env| to_s }

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end
  end

  class Integer < Number
    def initialize( value )
      @value = value.to_i
    end

    def numerator
      value
    end

    def denominator
      1 
    end

    def to_int
      value
    end

    BITWISE_OPS = [:&, :|, :^, :<<, :>>]

    BITWISE_OPS.each do |op|
      receive( op, 'n' ) do |env|
        value.send( op, env[:n] ).value
      end
    end

    receive( :integer?,  %q( () -> true ) )
    receive( :rational?, %q( () -> true ) )

    receive( :~           ) { |env| ~ value }
    receive( :numerator   ) { |env| numerator }
    receive( :denominator ) { |env| denominator }
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

    receive( :ratio?,    %q( () -> true ) )
    receive( :rational?, %q( () -> true ) )

    receive( :numerator )   { |env| numerator }
    receive( :denominator ) { |env| denominator }

    def to_r
      value
    end
  end

  class Float < Number
    def initialize( value )
      @value = value.to_f
    end

    receive( :float?, %q( () -> true ) )

    def to_f
      value
    end
  end

end

