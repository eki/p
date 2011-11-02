
module P

  class NocallExpr < ReducibleExpr
    def evaluate( environment )
      if first.id?
        name = first.to_sym

        if o = environment.local_get( name )
          o
        elsif o = environment.get( name )
          o
        else
          P.nil
        end
      end
    end
  end

end

