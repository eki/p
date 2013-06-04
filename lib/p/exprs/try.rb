
module P

  class TryExpr < Expr
    def evaluate( environment )
      begin
        first.evaluate( environment )
      rescue RaiseException => e
        re = list[1]

        if re.kind_of?( RescueExpr )
          re.evaluate( environment, P.error( e.value ) )
        end        

      ensure
        if last.kind_of?( EnsureExpr )
          last.evaluate( environment )
        end
      end
    end
  end

end

