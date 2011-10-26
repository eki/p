
module P

  class Environment < Object
    attr_reader :parent, :bindings

    def initialize( parent=Environment.top )
      @parent = parent

      @bindings = []
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
      "(#{bindings.map { |b| b.inspect }.join( ', ' )})"
    end

    def to_s
      inspect
    end

  end
end

