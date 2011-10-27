
module P

  class Nil < Object
    def ==( o )
      o.kind_of?( Nil ) 
    end

    def to_s
      ""
    end

    def inspect
      "nil"
    end
  end

end

