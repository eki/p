
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
      default? && default.glob?
    end

    def block?
      default? && default.amp?
    end

    def inspect
      if required?
        "#{name}"
      else
        "#{name}#{mutable? ? ' =' : ':'} #{default}"
      end
    end

    def to_s
      inspect
    end

    receive( :to_string ) { |env| to_s }
  end

  class Args
    attr_reader :list, :hash

    def initialize( *list )
      @list = list

      if list.length == 1 && list.first.kind_of?( Hash )
        @list, @hash = nil, @list.first
      end
    end

    def unshift( name, value )
      if by_name?
        hash[name] = value
      else
        list.unshift( value )
      end
    end

    def bind( parameters, environment, to_environment=environment )
      if by_name?
        bind_by_name( parameters, environment, to_environment )
      else
        bind_by_position( parameters, environment, to_environment )
      end
    end

    def by_name?
      !! hash
    end

    def by_position?
      ! by_name?
    end

    def bind_by_position( parameters, environment, to_env )
      parameters.each_with_index do |p,i|
        if p.glob?
          last_args = list[parameters.length - 1, list.length] || []

          to_env.bind( p.name, last_args.to_p )
        elsif arg = list[i]
          to_env.bind( p.name, arg.to_p )
        elsif p.default?
          to_env.bind( p.name, p.default.evaluate( to_env ) )
        else
          raise "Wrong number of arguments #{self} for #{parameters}"
        end
      end
    end

    def bind_by_name( parameters, environment, to_env )
      parameters.each do |p,i|
        if p.glob?
          last_args = hash.to_a[parameters.length - 1, hash.length] || []

          to_env.bind( p.name, Hash[last_args].to_p )
        elsif arg = hash.find { |k,v| p.name === k }
          to_env.bind( p.name, arg.last.to_p )
        elsif p.default?
          to_env.bind( p.name, p.default.evaluate( to_env ) )
        else
          raise "Wrong number of arguments #{self} for #{parameters}"
        end
      end
    end
  end

  class Function
    attr_reader :parameters, :code

    def initialize( parameters=[], code=nil )
      @parameters, @code = parameters, code
    end

    def eval( args, args_env, exec_env )
      args.bind( parameters, args_env, exec_env )
      code.evaluate( exec_env )
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

    def call( args, args_env, p_self=nil )
      exec_env = Environment.new( environment )
      exec_env.p_self = p_self  if p_self
      function.eval( args, args_env, exec_env )
    end

    def r_call( *args )
      call( Args.new( *args ), Environment.new, nil )
    end

    def eval( args, args_env, exec_env )
      env = environment.include( exec_env )
      v = function.eval( args, args_env, env )
      exec_env.copy( env )
      v
    end

    def r_eval( args, exec_env )
      eval( Args.new( *args ), Environment.new, exec_env )
    end

    def inspect
      function.inspect
    end

    def to_s
      inspect
    end

    receive( :environment ) { |env| environment }
    receive( :to_string )   { |env| to_s }

    receive( :call, 'args: *' ) do |env|
      r_call( *env[:args] )
    end
  end

  def self.closure( str )
    expr = P.parse( str ).first.first

    if expr.fn?
      expr.evaluate( Environment.top )
    end
  end

  class NativeFunction < Object
    attr_reader :block

    def initialize( params_string=nil, &block )
      if params_string
        params = case params_string
          when ::String
            P.parse( params_string ).first.first.to_params
          else params_string
        end
      else
        params = Expr.params
      end

      @parameters = params.evaluate
      @block = block
    end

    def call( args, args_env, p_self=nil )
      exec_env = Environment.new
      args.bind( parameters, args_env, exec_env )
      v = p_self ? p_self.instance_exec( exec_env, &block ) : block[exec_env]
      v.to_p
    end

    def r_call( *args )
      call( Args.new( *args ), Environment.new )
    end

    def inspect
      "(#{parameters.map { |p| p.inspect }.join( ', ' )}) -> <native code>"
    end

    def to_s
      inspect
    end

    receive( :to_string ) { |env| to_s }

    receive( :call, 'args: *' ) do |env|
      r_call( *env[:args] )
    end
  end

end

