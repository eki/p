
module P

  class ArgsExpr < Expr

    def bind( parameters, environment )
      if by_name?
        bind_by_name( parameters, environment )
      else
        bind_by_position( parameters, environment )
      end
    end

    def bind_by_position( parameters, environment )
      parameters.each_with_index do |p,i|
        if arg = list[i]
          environment.bind( p.name, arg.evaluate( environment ) )
        elsif p.default?
          environment.bind( p.name, p.default.evaluate( environment ) )
        else
          raise "Wrong number of arguments #{self} for #{parameters}"
        end
      end
    end

    def by_position?
      ! by_name?
    end

    def bind_by_name( parameters, environment )
      parameters.each do |p,i|
        if arg = list.find { |pair| p.name === pair.left.value }
          environment.bind( p.name, arg.right.evaluate( environment ) )
        elsif p.default?
          environment.bind( p.name, p.default.evaluate( environment ) )
        else
          raise "Wrong number of arguments #{self} for #{parameters}"
        end
      end
    end

    def by_name?
      if list.any? { |e| e.pair? }
        if list.all? { |e| e.pair? }
          return true
        else
          raise "If any args are passed by name, they must all be: #{args}"
        end
      end
    end
  end

end

