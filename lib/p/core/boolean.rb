
module P

  class Boolean

    def self.for( v )
      if v.to_s == 'true'
        True.new
      else
        False.new
      end
    end

    def p_send( m, *args )
      case m
        when :new         then Boolean.for( args.first )

        else Nil.new
      end 
    end


  end

end

