
module P

  GLOB  = '*'
  BLOCK = '&'

  class Parameter < Object
    attr_reader :name, :default

    def initialize( name, opts={ mutable: false, required: true } )
      @name     = name
      @mutable  = !! opts[:mutable]
      @required = !! opts[:required]

      @default  = opts[:default]
    end

    def mutable?
      @mutable
    end

    def immutable?
      ! @mutable
    end

    def required?
      @required
    end

    def optional?
      ! @required
    end

    def default?
      optional?
    end

    def glob?
      default == GLOB
    end

    def block?
      default == BLOCK
    end

    def inspect
      if required?
        "#{name}"
      else
        "#{name}#{mutable? ? ' =' : ':'} #{default}"
      end
    end
  end

  class Function < Object
    attr_reader :parameters, :code

    def initialize( parameters=[], code=nil )
      @parameters, @code = parameters, code
    end

    def eval( args, environment )
      code.evaluate( environment )
    end

    def inspect
      "(#{parameters.map { |p| p.inspect }.join( ', ' )}) -> #{code}"
    end

    def to_s
      inspect
    end
  end

  class Closure < Object
    attr_reader :function, :environment

    def initialize( function, environment )
      @function, @environment = function, environment
    end

    def call( args=[], env=nil )
      if env
        env.parent = environment
      else
        env = Environment.new( environment )
      end

      function.eval( args, env )
    end

    def inspect
      function.inspect
    end

    def to_s
      inspect
    end
  end

end

