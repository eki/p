
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

    def evaluate( environment )
      if list.empty?
        P.nil
      else
        raise "Attempt to evaluate non-nil seq."
      end
    end

    def to_params
      Expr.params( *list )
    end

    def to_args
      Expr.args( *list )
    end

    def to_seq
      self
    end

  end

end

