
module P

  class Binding < Object
    attr_reader   :name
    attr_accessor :value

    def initialize( name, value, mutable=false )
      @name, @value, @mutable = name, value, !! mutable
    end

    def p_send( m, *args )
      case m
        when :to_s         then String.new( inspect )
        when :name         then name
        when :value        then value
        when :'mutable?'   then Boolean.for( mutable? )
        when :'immutable?' then Boolean.for( immutable? )

        else Nil.new
      end 
    end

    def mutable?
      @mutable
    end

    def immutable?
      ! @mutable
    end

    def inspect
      "#{name}#{mutable? ? ' =' : ':'} #{value}"
    end
  end

end

