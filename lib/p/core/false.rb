
module P

  class False < Object
    def inspect
      'false'
    end

    def to_s
      'false'
    end

    def ==( o )
      o.kind_of?( False )
    end
  end
end

