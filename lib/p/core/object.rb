
module P
  class ObjectBuilder
    attr_reader :bindings

    def initialize( &block )
      @bindings = []

      instance_eval( &block )
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
      receive_capture[name.to_sym] = [obj, block]
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

    def self.receive_capture
      @receive_capture ||= {}
    end

    def self.p_get( name )
      name               = name.to_sym
      @receive         ||= {}

      if @receive[name]
        @receive[name]

      elsif receive_capture.key?( name )
        obj, block = receive_capture[name]

        r_get( name, obj, &block )
      elsif superclass.respond_to?( :p_get )
        superclass.p_get( name )
      end
    end

    def _receive
      self.class.receive_capture.keys
    end

    def slots
      _bindings.map { |b| b.name } + _receive
    end

    def methods
      slots.reject { |n| n.to_s =~ /^@/ }
    end

    def instance_variables
      slots.select { |n| n.to_s =~ /^@/ }
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
      end
    end

    def _p_get( name )
      self.class.p_get( name )
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

    def _binding_for( name )
      _bindings.find { |b| b.name == name.to_sym } ||
       (prototype && prototype._binding_for( name ))
    end


    # NOTE:  p_send takes an optional p_self argument.  This is used when doing
    #        prototype chaining so, if the prototype then performs a dependent
    #        p_send it can be routed to the original object.  This allows
    #        clones to override the behavior of the prototype.
    #
    #        However, this screws up the resolution of some native objects,
    #        whose receive blocks expect self to be the native object, not
    #        some "child".  For example, cloning a number like 3 will break
    #        and p_sends (like numerator, to_string, etc) that depend on
    #        value being 3.  The clones value will be nil, of course.

    # Suggested solution:
    #   1.  Only use receive when accessing ruby self.
    #   2.  Move all receives off P::Object.
    #   3.  Create base object that (may) receive and can act as a prototype.
    #   4.  _local_get needs to be expanded below, use p_self with actual
    #       bound objects, use self with p_get native functions.
    #
    # This solution is still not perfect, because it means p_get native
    # functions cannot use p_send to discover fields in their clones -- but
    # none of the native objects do this now.


    def p_send( name, args, args_env, p_self=self )
      if receiver = _local_get( name )
        receiver.call( args, args_env, p_self )
      elsif receiver = _p_get( name )
        receiver.call( args, args_env, self )
      elsif prototype
        prototype.p_send( name, args, args_env, p_self || self )
      else
        args.unshift( 'name', name.to_p )
        p_send( :method_missing, args, args_env, p_self || self )
      end
    end

    def r_send( name, *args )
      p_send( name, Args.new( *args ), Environment.new )
    end

    def call( args, args_env, p_self=nil )
      if o = _get( :call )
        p_send( :call, args, args_env, p_self )
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
  end

  def self.object
    @object ||= Object.build( prototype: nil ) do
      bind( :to_list,        fn { |env| P.list( self ) } )

      bind( :to_string,      fn do |env| '' 
        if P.true?( r_send( :respond_to?, :to_literal ) )
          r_send( :to_literal )
        else
          ''
        end
      end )

      bind( :prototype,          fn { |env| prototype } )
      bind( :identity,           fn { |env| object_id } )
      bind( :methods,            fn { |env| methods } )
      bind( :instance_variables, fn { |env| instance_variables } )
      bind( :nil?,               %q( () -> false ) )

      bind( :==,             fn( 'o' )       { |env| self == env[:o] } )
      bind( :respond_to?,    fn( 'name' )    { |env| !! _get( env[:name] ) } )

      bind( :send, fn( 'name, args: *' ) do |env|
        r_send( env[:name], *env[:args] )
      end )

      bind( :method_missing, fn( 'name, args: *' ) do |env| 
        if P.true?( env[:args].r_send( :empty? ) )
          P.nil
        else
          raise "Error: no method #{env[:name]} for #{self} with #{env[:args]}"
        end
      end )

      bind( :call, fn( 'args: *' ) do |env|
        if P.true?( env[:args].r_send( :empty? ) )
          self
        else
          raise "Error:  #{self} called with #{env[:args]}"
        end
      end )

      bind( :clone, fn( 'f: ?' ) do |env|
        f = env[:f]

        if P.true?( f )
          e = Environment.new
          f.r_eval( [], e )       # e will contain the bindings created by f
          bindings = e.bindings
        else
          bindings = []
        end

        instance_variables.each do |ivar|
          unless bindings.any? { |b| b.name == ivar } 
            bindings << Binding.copy( _binding_for( ivar ) )
          end
        end

        Object.new( prototype: self, bindings: bindings )
      end )

    end
  end

end

