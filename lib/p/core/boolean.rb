
module P

  class Boolean

    def self.for( v )
      if v.to_s == 'true'
        True.new
      else
        False.new
      end
    end

  end

end

