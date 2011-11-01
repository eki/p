
module P

  class String < Object
    attr_reader :value

    def initialize( value='' )
      @value = value.to_s
    end

    def inspect
      %Q("#{value}")
    end

    def to_s
      value
    end

    def length
      value.length
    end

    receive( :length )    { |env| P.number( length ) }
    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

    receive( :string?, %q( () -> true ) )
  end

  def self.string( v )
    String.new( v )
  end

end

