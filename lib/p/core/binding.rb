
module P

  class Binding

    attr_reader :name, :value, :mutable

    def initialize( name, value=nil, mutable=false )
      @name, @value, @mutable = name, value, mutable
    end

    def p_send( m, *args )
      case m
        when :to_s        then String.new( inspect )
        when :name        then name
        when :value       then value
        when 'mutable?'   then 

        else Nil.new
      end 
    end

    def inspect
      "<Binding #{name}: #{value} (#{mutable ? 'mutable' : 'immutable'})>"
    end


  end

end

