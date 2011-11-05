
module P

  class GlobExpr < Atom
    def evaluate( environment )
      Parameter::GLOB
    end
  end

end

