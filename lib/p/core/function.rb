
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
      args.bind( parameters, environment )
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

    def call( args=Expr.args, env=nil )
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

  class NativeFunction < Object
    attr_reader :parameters, :block

    def initialize( params_string="", &block )
      if params_string
        params = P.parse( params_string ).first.first.to_params
      else
        params = Expr.params
      end

      @parameters = params.evaluate( nil )  # eliminate the arg to params.evaluate
      @block = block
    end

    def call( args=Expr.args, env=nil )
      env = Environment.new
      args.bind( parameters, env )
      block[env]
    end

    def inspect
      "(#{parameters.map { |p| p.inspect }.join( ', ' )}) -> <native code>"
    end

    def to_s
      inspect
    end
  end

end

