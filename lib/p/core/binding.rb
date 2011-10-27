
module P

  class Binding < Object
    attr_reader   :name
    attr_accessor :value

    def initialize( name, value, mutable=false )
      @name, @value, @mutable = name, value, !! mutable
    end

    p_receive( :name )         { |env| name }
    p_receive( :value )        { |env| value }
    p_receive( :'mutable?' )   { |env| Boolean.for( mutable? ) }
    p_receive( :'immutable?' ) { |env| Boolean.for( immutable? ) }

    def mutable?
      @mutable
    end

    def immutable?
      ! @mutable
    end

    def inspect
      "#{name}#{mutable? ? ' =' : ':'} #{value}"
    end

    def to_s
      inspect
    end
  end

end

