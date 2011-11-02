
module P

  class List < Object
    include Enumerable

    attr_reader :value

    def initialize( *objs )
      @value = *objs
    end

    def first
      value.first
    end

    def last
      value.last
    end

    def []( index )
      value[index]
    end

    def empty?
      value.empty?
    end

    def rest
      P.list( *value[1..(value.length)] )
    end

    def length
      value.length
    end

    def each( &block )
      value.each( &block )
    end

    receive( :list?, %q( () -> true ) )

    receive( :first       ) { |env| first }
    receive( :rest        ) { |env| rest }
    receive( :last        ) { |env| last }
    receive( :empty?      ) { |env| empty? }
    receive( :length      ) { |env| length }
    receive( :to_literal  ) { |env| to_literal }
    receive( :to_string   ) { |env| to_literal }
    receive( :to_list     ) { |env| self }
    receive( :[], 'index' ) { |env| self[env[:index].r_send( :to_integer )] }

    def to_s
      value.to_s
    end

    def to_literal
      to_s  # This should really be formatted to match a parsable literal
    end

    def inspect
      value.inspect
    end

    def to_ary
      value
    end
  end

  def self.list( *objs )
    List.new( *objs )
  end

end

