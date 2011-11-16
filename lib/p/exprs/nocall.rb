
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
      elsif first.send?
        name = first.list[1].to_sym
        if o = first.list[0].evaluate( environment )._get( name )
          o
        else
          P.nil
        end
      elsif first.atom?
        first.evaluate( environment )
      end
    end
  end

end

