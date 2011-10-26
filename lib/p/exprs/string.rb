
module P

  class StringExpr < Atom
    def evaluate( environment )
      String.new( value )
    end
  end

end

