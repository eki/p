
module P

  class Object
    def self.p_receive( name, params_string=nil, &block )
      @receive ||= {}

      if params_string
        params = P.parse( params_string ).first.first.to_params
      else
        params = Expr.params
      end

      @receive[name.to_sym] = [params, block]
    end

    def self.receive( name )
      r = @receive || {}

      if self == Object
        r[name]
      else
        r[name] || superclass.receive( name )
      end
    end

    def p_receive( name, args, environment )
      params, block = self.class.receive( name )

      if params && block
        env = Environment.new
        args.bind( params.evaluate( environment ), environment, env )
        instance_exec( env, &block )
      end
    end

    p_receive( :to_s )      { |env| String.new( to_s ) }
    p_receive( :==, "obj" ) { |env| Boolean.for( self == env.get( 'obj' ) ) }

    def p_send( m, args, environment )
      p_receive( m, args, environment ) || Nil.new
    end

    def to_s
      ""
    end

    def call( args=[], environment=Environment.top )
      return self
    end
  end

end

