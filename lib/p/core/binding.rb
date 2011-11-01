
module P

  class Binding < Object
    attr_reader   :name
    attr_accessor :value

    def initialize( name, value, mutable=false )
      @name, @value, @mutable = name, value, !! mutable
    end

    def mutable?
      @mutable
    end

    def immutable?
      ! @mutable
    end

#   def inspect
#     "#{name}#{mutable? ? ' =' : ':'} #{value.inspect}"
#   end

    def to_s
      inspect
    end

    receive( :name )       { |env| P.string( name ) }
    receive( :value )      { |env| value }
    receive( :mutable? )   { |env| P.boolean( mutable? ) }
    receive( :immutable? ) { |env| P.boolean( immutable? ) }

    receive( :inspect )   { |env| P.list( P.string( 'name' ), P.string( 'value'
), P.string( 'mutable?' ) ) }
    receive( :to_string ) { |env| P.string( to_s ) }
  end

end

