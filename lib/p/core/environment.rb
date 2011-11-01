
module P

  class Environment < Object
    attr_reader :parent, :bindings, :p_self

    def initialize( parent=Environment.top, &block )
      @parent = parent
      @bindings = []

      instance_eval( &block )  if block_given?
    end

    def p_self=( object )
      @p_self = object
      bind( :self, object )
    end

    def bind( name, value )
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
          if b.mutable?
            set( b.name, b.value )
          else
            bind( b.name, b.value )
          end
        end
      end
    end

    def flatten( env=Environment.new( nil ) )
      bindings.each do |b|
        unless env.binding_for( b.name )
          if b.mutable?
            env.set( b.name, b.value )
          else
            env.bind( b.name, b.value )
          end
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
          if b.mutable?
            set( b.name, b.value )
          else
            bind( b.name, b.value )
          end
        end
      end
    end

    def copy( env )
      env.bindings.each do |b|
        if b.mutable?
          set( b.name, b.value )
        else
          bind( b.name, b.value )
        end
      end
    end

    def binding_for( name )
      name = name.to_sym

      bindings.find { |b| b.name == name } ||
      (parent && parent.binding_for( name ))
    end

    def inspect
      "(#{bindings.map { |b| b.inspect }.join( ', ' )})"
    end

    def to_s
      inspect
    end

    receive( :bindings         ) { |env| P.list( *bindings ) }
    receive( :get,      'name' ) { |env| get( env[:name] ) }
    receive( :defined?, 'name' ) { |env| P.boolean( defined?( env[:name] ) ) }

    receive( :set, 'name,value' ) do |env| 
      set( env[:name], env[:value] )
    end

    receive( :bind, 'name,value' ) do |env| 
      bind( env[:name], env[:value] )
    end

    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }


    def self.top
      return @top  if @top

      @top ||= Environment.new( nil ) do
        bind( :puts, P.nf( :puts ) )
        bind( :new,  P.nf( :new ) )
      end
    end
  end

  def self.environment( parent=nil )
    Environment.new( parent || Environment.top )
  end

end

