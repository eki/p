
module P

  class Nil

    def p_send( m, *args )
      case m
        when :to_s        then String.new( 'nil' )

        else Nil.new
      end 
    end



  end

end

