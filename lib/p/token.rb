
module P

  class Token
    attr_reader :name, :value, :position, :line, :character, :indent

    def initialize( name, value, position, line, character, indent=nil )
      @name, @value = name.to_sym, value
      @position, @line, @character = position, line, character
      @indent = indent
    end

    def inspect
      v = value.gsub( /\n/, '\\n' )
      %Q("#{v}")
    end

    def debug
      i = ", indent: #{indent}"  if indent
      v = value.gsub( /\n/, '\\n' )
      "<Token #{name}='#{v}', #{line}:#{character}#{i}>"
    end

    def to_s
      inspect
    end

    def to_sym
      name
    end

    def ===( o )
      o && o.respond_to?( :to_sym ) && name == o.to_sym
    end

    def =~( p )
      value =~ p
    end

    def rename( name )
      @name = name.to_sym
    end

    def method_missing( m, *args, &block )
      if m.to_s =~ /(.*)\?$/
        name.to_s == $1
      else
        super
      end
    end

  end

end

