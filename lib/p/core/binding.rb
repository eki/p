
module P

  class Binding < Object
    attr_reader   :name
    attr_accessor :value

    def initialize( name, value, mutable=false )
      @name, @value, @mutable = name, value, !! mutable
    end

    def self.copy( binding, opts={} )
      new( opts[:name]  || binding.name, 
           opts[:value] || binding.value, 
           opts.key?( :mutable? ) ? opts[:mutable?] : binding.mutable? )
    end

    def mutable?
      @mutable
    end

    def immutable?
      ! @mutable
    end

    def inspect
      "#{name}#{mutable? ? ' =' : ':'} #{value.inspect}"
    end

    def to_s
      inspect
    end

    receive( :name )       { |env| name }
    receive( :value )      { |env| value }
    receive( :mutable? )   { |env| mutable? }
    receive( :immutable? ) { |env| immutable? }

    receive( :inspect )   { |env| [:name, :value, :mutable?] }
    receive( :to_string ) { |env| to_s }
  end

end

