
module P

  class List < Object
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

    receive( :first     ) { |env| first }
    receive( :rest      ) { |env| rest }
    receive( :last      ) { |env| last }
    receive( :empty?    ) { |env| P.boolean( empty? ) }
    receive( :length    ) { |env| P.number( length ) }

    receive( :inspect   ) { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

    receive( :to_list   ) { |env| self }

    receive( :[], 'index' ) do |env| 
      index = env[:index].r_send( :to_integer )
      obj = self[index]
      obj ? obj : P.nil
    end

    def to_s
      value.to_s
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

