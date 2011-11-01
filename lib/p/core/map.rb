
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

    receive( :map?,      %q( () -> true ) )

    receive( :empty?     ) { |env| empty? }
    receive( :length     ) { |env| length }
    receive( :keys       ) { |env| keys }
    receive( :values     ) { |env| values }
    receive( :[], 'key'  ) { |env| self[env[:index]] }
    receive( :to_string  ) { |env| to_s }

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

