
module P

  class StringExpr < Atom
    def evaluate( environment )
      P.string( value )
    end

    def to_s
      %Q("#{value.gsub( /\n/, '\n' )}")
    end

  end
end

