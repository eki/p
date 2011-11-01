
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

    MATH_OPS = [:+, :-, :*, :/, :%, :<=>, :**]

    COMP_OPS = [:<, :>, :<=, :>=]

    MATH_OPS.each do |op|
      receive( op, 'n' ) do |env|
        P.number( value.send( op, env[:n].value ) ) # coerce ?  to_number ?
      end
    end

    COMP_OPS.each do |op|
      receive( op, 'n' ) do |env|
        P.boolean( value.send( op, env[:n].value ) ) # coerce ?  to_number ?
      end
    end

    receive( :number?, %q( () -> true ) )

    receive( :to_float )    { |env| Float.new( value ) }
    receive( :to_integer )  { |env| Integer.new( value ) }
    receive( :to_ratio )    { |env| Ratio.new( value ) }
    receive( :to_rational ) { |env| P.number( Ratio.new( value ) ) }

    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

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

    BITWISE_OPS = [:&, :|, :^, :<<, :>>]

    BITWISE_OPS.each do |op|
      receive( op, 'n' ) do |env|
        P.number( value.send( op, env[:n] ).value )
      end
    end

    receive( :integer?,  %q( () -> true ) )
    receive( :rational?, %q( () -> true ) )

    receive( :~ ) { |env| P.number( ~ value ) }

    receive( :numerator )   { |env| P.number( numerator ) }
    receive( :denominator ) { |env| P.number( denominator ) }
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

    receive( :numerator )   { |env| P.number( numerator ) }
    receive( :denominator ) { |env| P.number( denominator ) }
  end

  class Float < Number
    def initialize( value )
      @value = value.to_f
    end

    receive( :float?, %q( () -> true ) )
  end

end

