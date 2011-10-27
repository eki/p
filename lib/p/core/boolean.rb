
module P

  class Boolean

    def self.for( v )
      if v.to_s == 'true'
        True.new
      else
        False.new
      end
    end

    def self.true?( v )
      ! (v.kind_of?( Nil ) || v.kind_of?( False ))
    end

    def self.false?( v )
      ! true?( v )
    end

  end

end

