
module P

  class List < Object
    attr_reader :value

    def initialize( *objs )
      @value = *objs
    end

    def initialize_copy( original )
      @value = original.value.map { |o| o.dup }
    end

    p_receive( :'list?' )  { |env| True.new }
    p_receive( :'first' )  { |env| value.first }
    p_receive( :'rest' )   { |env| List.new( *value[1..(value.length)] ) }
    p_receive( :'last' )   { |env| value.last }
    p_receive( :'empty?' ) { |env| Boolean.for( value.empty? ) }
    p_receive( :length )   { |env| P.number( value.length ) }

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end

    def ==( o )
      o.kind_of?( List ) && value == o.value
    end
  end

end

