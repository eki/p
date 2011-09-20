
module P

  class False

    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'false' )

        else Nil.new
      end 
    end

    def inspect
      'false'
    end

    def to_s
      'false'
    end



  end

end

