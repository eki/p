
module P

  class True < Object

    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'true' )

        else Nil.new
      end 
    end

    def inspect
      'true'
    end

    def to_s
      'true'
    end

    def ==( o )
      o.kind_of?( True ) 
    end

  end

end

