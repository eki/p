
module P

  class String < Object
    attr_reader :value

    def initialize( value='' )
      @value = value.to_s
    end

    def inspect
      to_literal
    end

    def to_literal
      %Q("#{value}")
    end

    def to_str
      value
    end

    def to_s
      value
    end

    def length
      value.length
    end

    receive( :length     ) { |env| length }
    receive( :to_literal ) { |env| to_literal }
    receive( :to_string  ) { |env| to_s }

    receive( :string?, %q( () -> true ) )
  end

  def self.string( v )
    String.new( v )
  end

end

