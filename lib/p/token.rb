
module P

  class Token
    attr_reader :name, :value, :line, :character, :indent

    def initialize( name, value, line, character, indent=nil )
      @name, @value, @line, @character = name.to_sym, value, line, character
      @indent = indent
    end

    def inspect
    # i = ", indent: #{indent}"  if indent
      v = value.gsub( /\n/, '\\n' )
    # "<Token #{name}='#{v}', #{line}:#{character}#{i}>"
      %Q("#{v}")
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

    def method_missing( m, *args, &block )
      if m.to_s =~ /(.*)\?$/
        name.to_s == $1
      else
        super
      end
    end

  end

end

