
module P

  class ParamsExpr < Expr

    def evaluate( environment )
      list.map do |expr|
        if expr.pair? && expr.left.id?
          Parameter.new( String.new( expr.left.value ),
            required: false, default: expr.right )
        elsif expr.id?
          Parameter.new( String.new( expr.value ) )
        else
          raise "Malformed parameter: #{expr} in #{list}"
        end
      end
    end

  end

end

