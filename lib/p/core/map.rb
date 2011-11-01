
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

    def get( key )
      value[key] || P.nil
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

    # temporary until [] notation is added

    receive( :get, 'key' ) { |env| get( env[:key] ) }

    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end
  end

end

