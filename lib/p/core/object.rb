
module P

  class Object

    attr_reader :bindings

    def initialize( bindings )
      @bindings = bindings
    end

    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'object' )

        else Nil.new
      end 
    end


  end

end

