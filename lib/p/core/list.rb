
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

    def empty?
      value.empty?
    end

    def rest
      P.list( *value[1..(value.length)] )
    end

    def length
      value.length
    end

    receive( :list?, %q( () -> true ) )

    receive( :first )  { |env| first }
    receive( :rest )   { |env| rest }
    receive( :last )   { |env| last }
    receive( :empty? ) { |env| P.boolean( empty? ) }
    receive( :length ) { |env| P.number( length ) }

    receive( :inspect )   { |env| P.string( inspect ) }
    receive( :to_string ) { |env| P.string( to_s ) }

    def to_s
      value.to_s
    end

    def inspect
      value.inspect
    end
  end

  def self.list( *objs )
    List.new( *objs )
  end

end

