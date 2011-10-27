
module P

  class SendExpr < Expr
    def evaluate( environment )
      obj  = list[0].evaluate( environment )
      msg  = list[1].to_sym
      args = list[2]

      obj.p_send( msg, args, environment )
    end

    def to_s
      if list[2].list.empty?
        "(#{list[0]}.#{list[1]})"
      else
        "(#{list[0]}.#{list[1]}( #{list[2].list.join( ', ' )} ))"
      end
    end
  end

end

