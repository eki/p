
module P

  class PObject < Object
    attr_reader :prototype, :bindings

    def initialize( environment, prototype=nil )
      @bindings = environment.bindings.map { |b| b.dup }
      @prototype = prototype
    end

    def get( name )
      if b = bindings.find { |b| b.name === name }
        b.value
      end
    end

    def p_send( m, args, environment )
      if o = get( String.new( m ) )   # may not need to wrap m in String.new
        o.call( args )
      else
        p_receive( m, args, environment )                       ||
        (prototype && prototype.p_send( m, args, environment )) ||
        Nil.new
      end
    end

    def inspect
      "(Object #{bindings})"
    end

    def to_s
      inspect
    end

  end

end

