
module P

  class Environment < Object
    attr_reader :parent, :bindings

    def initialize( parent=Environment.top, &block )
      @parent = parent
      @bindings = []

      instance_eval( &block )  if block_given?
    end

    def p_self=( object )
      @p_self = object
      bind( :self, object )
    end

    def p_self
      @p_self || (parent && parent.p_self)
    end

    def bind( name, value, mutable=false )
      return set( name, value )  if mutable

      name = name.to_sym

      if bindings.any? { |b| b.name === name }
        raise "Error: #{name} already bound locally."
      end

      bindings << Binding.new( name, value )

      value
    end

    def defined?( name )
      name = name.to_sym

      bindings.any? { |b| b.name == name } ||
      (parent && parent.defined?( name ))
    end

    def local_get( name )
      name = name.to_sym

      if binding = bindings.find { |b| b.name == name }
        binding.value
      end
    end

    def get( name )
      name = name.to_sym

      if binding = binding_for( name )
        binding.value
      elsif name == :environment
        self
      else
        P.nil
      end
    end

    def []( name )
      get( name )
    end

    def set( name, value )
      name = name.to_sym

      if p_self && binding = p_self._binding_for( name )
        if binding.mutable?
          return binding.value = value
        end
      end

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

    def unchain
      Environment.new( nil ) do
        bindings.each do |b|
          bind( b.name, b.value, b.mutable? )
        end
      end
    end

    def flatten( env=Environment.new( nil ) )
      bindings.each do |b|
        unless env.binding_for( b.name )
          env.bind( b.name, b.value, b.mutable? )
        end
      end

      if parent
        env = parent.flatten( env )
      end

      env
    end

    def include( env )
      Environment.new( self ) do
        env.bindings.each do |b|
          bind( b.name, b.value, b.mutable? )
        end
      end
    end

    def copy( env )
      env.bindings.each do |b|
        bind( b.name, b.value, b.mutable? )
      end
    end

    def binding_for( name )
      name = name.to_sym

      bindings.find { |b| b.name == name } ||
      (parent && parent.binding_for( name ))
    end

    def inspect
      is = bindings.map do |b| 
        (b.value == self ? Binding.copy( b, value: '...'.to_p ) : b)
      end

      "(#{is.map { |b| b.inspect }.join( ', ' )})"
    end

    def to_s
      inspect
    end

    receive( :to_string        ) { |env| to_s }
    receive( :bindings         ) { |env| bindings }
    receive( :[],       'name' ) { |env| get( env[:name] ) }
    receive( :defined?, 'name' ) { |env| defined?( env[:name] ) }

    receive( :[]=, 'name,value' ) do |env| 
      set( env[:name], env[:value] )
    end

    receive( :bind, 'name, value, mutable: false' ) do |env| 
      bind( env[:name], env[:value], P.true?( env[:mutable] ) )
    end

    def self.top
      return @top  if @top

      @top ||= Environment.new( nil ) do
        bind( :print,        P.nf( :print ) )
        bind( :puts,         P.nf( :puts ) )
        bind( :new,          P.nf( :new ) )
        bind( :inspect,      P.nf( :inspect ) )
        bind( :require,      P.nf( :require ) )
        bind( :test,         P.nf( :test ) )
        bind( :assert,       P.nf( :assert ) )
        bind( :assert_equal, P.nf( :assert_equal ) )
      end
    end
  end

  def self.environment( parent=nil )
    Environment.new( parent || Environment.top )
  end

end

