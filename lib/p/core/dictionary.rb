
module P

  class Dictionary

    attr_reader :map

    def initialize( expr=nil )
      @map = Hash.new( Nil.new )
    end

  end

end

