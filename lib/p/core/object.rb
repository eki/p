
module P
  class ObjectBuilder
    attr_reader :bindings

    def initialize( &block )
      @bindings = []

      instance_eval( &block )

      unless bindings.any? { |b| b.name == :to_string }
        bind( :to_string, P.nf( :default_to_string ) )
      end
    end

    def bind( name, value )
      name, value = parse_name( name ), parse_value( value )

      if bindings.any? { |b| b.name === name }
        raise "Error: #{name} already bound locally."
      end

      bindings << Binding.new( name, value )

      value
    end

    def set( name, value )
      name, value = parse_name( name ), parse_value( value )

      if parent && binding = parent.binding_for( name )
        if binding.mutable?
          return binding.value = value
        end
      end

      if binding = bindings.find { |b| b.name === name }
        if binding.immutable?
          raise "Error: attempt to change immutable binding of #{name}."
        end

        binding.value = value
      else
        bindings << Binding.new( name, value, true )
        value
      end
    end

    def fn( params=nil, &block )
      NativeFunction.new( params, &block )
    end

    private

    def parse_value( value )
      if value.kind_of?( ::String )
        P.parse( value ).first.first.evaluate( Environment.new )
      else
        value
      end
    end

    def parse_name( name )
      name.to_sym
    end
  end

  class Object
    attr_reader :value

    def initialize( opts={} )
      @_ ||= {}

      @_[:prototype] = opts[:prototype]  if opts.key?( :prototype )
      @_bindings     = opts[:bindings]   if opts[:bindings]
      @parameters    = opts[:parameters] if opts[:parameters]
    end

    def self.build( opts={}, &block )
      new( opts.merge( bindings: ObjectBuilder.new( &block ).bindings ) )
    end

    def self.receive( name, obj=nil, &block )
      @receive_capture ||= {}
      @receive_capture[name.to_sym] = [obj, block]
    end

    def self.r_get( name, obj=nil, &block )
      @receive ||= {}

      @receive[name] ||= case obj
        when ::String
          expr = P.parse( obj ).first.first

          if expr.fn?
            expr.evaluate( Environment.top )
          elsif block_given?
            NativeFunction.new( expr.to_params, &block )
          else
            expr.evaluate( Environment.new )
          end

        when Object then obj

        else
          if block_given?
            NativeFunction.new( Expr.params, &block )
          else
            raise "How to make an P::Object from #{obj}:#{obj.class}"
          end
      end
    end

    def self.p_get( name )
      name               = name.to_sym
      @receive         ||= {}
      @receive_capture ||= {}

      if @receive[name]
        @receive[name]

      elsif @receive_capture.key?( name )
        obj, block = @receive_capture[name]

        r_get( name, obj, &block )
      elsif superclass.respond_to?( :p_get )
        superclass.p_get( name )
      end
    end

    def prototype
      @_ ||= {}
      @_.key?( :prototype ) ? @_[:prototype] : (@_[:prototype] ||= P.object)
    end

    def _bindings
      @_bindings ||= []
    end

    def parameters
      @parameters ||= Expr.params.evaluate
    end

    def _local_get( name )
      if binding = _bindings.find { |b| b.name == name.to_sym }
        binding.value
      elsif o = self.class.p_get( name )
        o
      end
    end

    def _get( name )
      if binding = _bindings.find { |b| b.name == name.to_sym }
        binding.value
      elsif o = self.class.p_get( name )
        o.to_p
      elsif prototype
        prototype._get( name )
      end
    end

    def p_send( name, args, args_env )
      if receiver = _local_get( name )
        receiver.call( args, args_env, self )
      elsif prototype
        prototype.p_send( name, args, args_env )
      else
        p_send( :method_missing, args, args_env )
      end
    end

    def r_send( name, *args )
      p_send( name, Args.new( *args ), Environment.new )
    end

    def call( args, args_env, p_self=nil )
      if o = _get( :call )
        p_send( :call, args, args_env )
      else
        self
      end
    end

    def r_call( *args )
      call( Args.new( *args ), Environment.new )
    end

    def ==( o )
      value ? value == o.value : super
    end

    def eql?( o )
      self == o
    end

    def hash
      value ? value.hash : super
    end

    def inspect
      P.nf( :inspect ).r_call( self ).to_s
    end

    def to_s
      r_send( :to_string ).to_s
    end

    def to_sym
      to_s.to_sym
    end

    def to_p
      self
    end

    receive( :==, 'o'   ) { |env| P.boolean( self == env[:o] ) }
    receive( :to_list   ) { |env| P.list( self ) }
    receive( :prototype ) { |env| prototype || P.nil }

    receive( :respond_to?, 'name' ) do |env|
      _get( env[:name] ) ? P.true : P.false
    end

    receive( :clone, 'f' ) do |env|
      f = env[:f]

      e = Environment.new
      f.r_eval( [], e )       # e will contain the bindings created by f

      Object.new( prototype: self, bindings: e.bindings )
    end

    receive( :method_missing, 'args: *' ) { |env| P.nil }
  end

  def self.object
    @object ||= Object.build( prototype: nil ) do
      bind( :to_string, fn { |env| P.string( "Object.prototype" ) } )
    end
  end

end

