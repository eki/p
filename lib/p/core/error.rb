
module P

  class Error < Object
    attr_reader :value

    def initialize( value )
      @value = value
    end

    def to_s
      value.to_s
    end

    receive( :to_string  ) { |env| to_s }

    receive( :error?, %q( () -> true ) )
  end

  def self.error( v )
    Error.new( v )
  end

end

