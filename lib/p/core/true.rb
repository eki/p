
module P

  class True < Object

    def inspect
      'true'
    end

    def to_s
      'true'
    end

    def ==( o )
      o.kind_of?( True ) 
    end

  end

end

