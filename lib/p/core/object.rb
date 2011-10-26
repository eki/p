
module P

  class Object
    def p_send( m, *args )
      case m.to_sym
        when :to_s        then String.new( to_s )
        when :==          then Boolean.for( self == args.first )

        else Nil.new
      end 
    end

    def to_s
      ""
    end

    def call( args=[], environment=Environment.top )
      return self
    end
  end

end

