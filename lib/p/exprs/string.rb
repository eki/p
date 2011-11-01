
module P

  class StringExpr < Atom
    def evaluate( environment )
      P.string( value )
    end
  end

end

