
module P

  class Environment < Object
    attr_reader :parent, :bindings

    def initialize( parent=Environment.top )
      @parent = parent

      @bindings = []

      bind( String.new( 'environment' ), self )
      bind( String.new( 'defined?' ), P.parse( '(name) -> environment.defined?( name )' ).first.first.evaluate( self ) ) # is this technically correct?

      bind( String.new( 'puts' ), FN[:puts] )
    end

    p_receive( :bind, "(name,value)" ) do |env|
      bind( env.get( 'name' ), env.get( 'value' ) )
    end

    p_receive( :set, "(name,value)" ) do |env|
      set( env.get( 'name' ), env.get( 'value' ) )
    end

    p_receive( :get, "(name)" ) do |env|
      get( env.get( 'name' ) )
    end

    p_receive( :defined?, "(name)" ) do |env|
      Boolean.for( self.defined?( env.get( 'name' ) ) )
    end

    p_receive( :bindings ) do |env|
      List.new( *bindings.reject { |b| b.name === 'environment' } )
    end

    def bind( name, value )
      if bindings.any? { |b| b.name === name }
        raise "Error: #{name} already bound locally."
      end

      bindings << Binding.new( name, value )

      value
    end

    def defined?( name )
      bindings.any? { |b| b.name === name } ||
      (parent && parent.defined?( name ))
    end

    def get( name )
      if binding = binding_for( name )
        binding.value
      end
    end

    def set( name, value )
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

    def self.top
      @top ||= Environment.new( nil )   # need to populate with core bindings
    end

    def binding_for( name )
      bindings.find { |b| b.name === name } ||
      (parent && parent.binding_for( name ))
    end

    def inspect
      bs = bindings.reject { |b| b.name === 'environment' }
      "(#{bs.map { |b| b.inspect }.join( ', ' )})"
    end

    def to_s
      inspect
    end

  end
end

