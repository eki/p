
module P

  class False < Object
    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'false' )

        else super
      end 
    end

    def inspect
      'false'
    end

    def to_s
      'false'
    end

    def ==( o )
      o.kind_of?( False )
    end
  end
end

