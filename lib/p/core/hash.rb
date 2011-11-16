
module P

  class Hash < Object
    include Enumerable

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

    def each( &block )
      value.each( &block )
    end

    receive( :map?,      %q( () -> true ) )
    receive( :hash?,     %q( () -> true ) )

    receive( :to_map     ) { |env| self }
    receive( :to_trie    ) { |env| P.trie( value ) }
    receive( :to_hash    ) { |env| self }


    receive( :empty?     ) { |env| empty? }
    receive( :length     ) { |env| length }
    receive( :keys       ) { |env| keys }
    receive( :values     ) { |env| values }
    receive( :[], 'key'  ) { |env| self[env[:key]] }
    receive( :to_literal ) { |env| to_literal }
    receive( :to_string  ) { |env| to_literal }

    receive( :each, 'fn' ) do |env|
      fn = env[:fn]
      arity = fn.r_send( :arity ).r_send( :to_integer ).to_int

      if arity == 1
        value.each { |k,v| fn.r_call( v ) }
      elsif arity == 2
        value.each { |k,v| fn.r_call( k, v ) }
      else
        raise "Each expected fn to take 1 or 2 args."
      end
    end

    def to_s
      to_literal
    end

    def to_literal
      "{#{map { |k,v| "#{k} => #{v}" }.join( ', ' )}}"
    end

    def inspect
      to_literal
    end

    def to_hash
      value
    end
  end

  def self.hash( h={} )
    Hash.new( h )
  end

end

