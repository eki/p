
module P

  class Nil < Object

    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'nil' )
        when :==
          Boolean.for( self == args.first )

        else Nil.new
      end 
    end

    def ==( o )
      o.kind_of?( Nil ) 
    end

    def to_s
      ""
    end

    def inspect
      "nil"
    end

  end

end

