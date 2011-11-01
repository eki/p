
module P

  class ParamsExpr < Expr

    def evaluate
      list.map do |expr|
        if expr.pair? && expr.left.id?
          Parameter.new( expr.left.value.to_sym,
            required: false, default: expr.right )
        elsif expr.id?
          Parameter.new( expr.value.to_sym )
        else
          raise "Malformed parameter: #{expr} in #{list}"
        end
      end
    end

  end

end

