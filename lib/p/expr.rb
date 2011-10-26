
module P

  class Expr
    attr_reader :name, :list

    def initialize( *list )
      @list = list
    end

    def name
      self.class.type
    end

    def to_s
      list.empty? ? "(#{name})" : "(#{name} #{list.join( ' ' )})"
    end

    def inspect
      to_s
    end

    def left
      list[0]
    end

    def right
      list[1]
    end

    def first
      list[0]
    end

    def method_missing( m, *args, &block )
      if m.to_s =~ /(.*)\?$/
        name.to_s == $1
      else
        super
      end
    end

    def flatten
      Expr.new( name, *list.map { |a| a.name == name ? a.list : a }.flatten )
    end

    def reduce?
      false
    end

    def reduce
      self
    end

    def pp( indent=0 )
      i, s = ' ' * indent, nil

      if list.empty? 
        s = "#{i}(#{name})"
      else
        s = "#{i}(#{name}\n#{list.map { |e| e.pp( indent+2 ) }.join( "\n" )})"
      end

      indent == 0 ? puts( s ) : s
    end

    def self.type
      name.gsub( /^.*::/, '' ).
           gsub( /([a-z])([A-Z]+)/, '\1_\2' ).downcase.
           gsub( /_expr/, '' ).to_sym
    end

    def self.inherited( base )
      (@all_subclasses ||= {})[base.type] = base
    end

    def self.method_missing( m, *args, &block )
      if (@all_subclasses || {}).key?( m )
        @all_subclasses[m].new( *args )
      else
        super
      end
    end
  end

  class ReducibleExpr < Expr
    def reduce?
      true
    end

    def reduce
      self.class.new( *list.map { |e| e.reduce? ? e.reduce : e } )
    end

    def evaluate( environment )
      reduce.evaluate( environment )
    end

    def self.inherited( base )
      Expr.inherited( base )
    end
  end

  class Atom < Expr
    attr_reader :value

    def initialize( value )
      @value = value
    end

    def name
      self.class.type
    end

    def to_s
      "(#{name} #{value})"
    end

    def pp( indent=0 )
      i = ' ' * indent
      s = "#{i}#{to_s}"

      indent == 0 ? puts( s ) : s
    end

    def evaluate( environment )
    end

    def flatten
      self
    end

    def list
      self
    end

    def atom?
      true
    end

    def self.inherited( base )
      Expr.inherited( base )
    end
  end

  class SendableOperatorExpr < ReducibleExpr
    def self.op( n )
      @op = n
    end

    def op
      self.class.instance_variable_get( '@op' )
    end

    def reduce
      SendExpr.new( 
        list[0].reduce, Expr.id( op ), Expr.params( list[1].reduce ) )
    end

    def to_s
      "(#{op} #{left} #{right})"
    end

    def self.inherited( base )
      Expr.inherited( base )
    end
  end

end

