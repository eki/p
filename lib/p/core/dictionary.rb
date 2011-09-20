
module P

  class Dictionary

    attr_reader :map

    def initialize( expr=nil )
      @map = Hash.new( Nil.new )
    end

    def p_send( m, *args )
      case m
        when :to_s        then String.new( @map.inspect )

        else Nil.new
      end 
    end


  end

end

