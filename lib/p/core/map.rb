
module P

  class Map < Object
    attr_reader :value

    def initialize( hash )
      @value = hash.to_hash
    end

    p_receive( :'map?' )   { |env| True.new }
    p_receive( :'empty?' ) { |env| Boolean.for( value.empty? ) }
    p_receive( :length )   { |env| P.number( value.length ) }

    # temporary until [] notation is added

    p_receive( :get, '(key)' ) do |env| 
      value[env.get( 'key' )] || Nil.new
    end

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end

    def ==( o )
      o.kind_of?( Map ) && value == o.value
    end
  end

end

