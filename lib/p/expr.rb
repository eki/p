
module P

  class Expr
    attr_reader :name, :list

    def initialize( name, *list )
      @name, @list = name, list
    end

    def to_s
      list.empty? ? "(#{name})" : "(#{name} #{list.join( ' ' )})"
    end

    def inspect
      to_s
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
  end

  class Atom < Expr
    attr_reader :value

    def initialize( name, value )
      @name, @value, @list = name, value, nil
    end

    def to_s
      "(#{name} #{value})"
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

  end

end

