
module P

  class Map < Object
    attr_reader :value

    def initialize( hash )
      @value = hash.to_hash
    end

    def empty?
      value.empty?
    end

    def length
      value.length
    end

    def []( key )
      value[key]
    end

    def keys
      value.keys
    end

    def values
      value.values
    end

    receive( :map?, %q( () -> true ) )

    receive( :empty? )     { |env| P.boolean( empty? ) }
    receive( :length )     { |env| P.number( length ) }

    receive( :keys )       { |env| P.list( *keys ) }
    receive( :values )     { |env| P.list( *values ) }

    receive( :[], 'key' ) do |env| 
      obj = self[env[:key]]
      obj ? obj : P.nil
    end

    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end

    def to_hash
      value
    end
  end

end

