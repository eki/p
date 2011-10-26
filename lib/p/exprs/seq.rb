
module P

  class SeqExpr < Expr
    def initialize( *list )
      @list = list.map do |expr|
        if expr.seq?
          expr.list
        else
          expr
        end
      end.flatten
    end

    def to_params
      Expr.params( *list )
    end

    def to_args
      Expr.args( *list )
    end

  end

end

