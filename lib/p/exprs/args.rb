
module P

  class ArgsExpr < Expr

    def bind( parameters, environment, to_environment=environment )
      if by_name?
        bind_by_name( parameters, environment, to_environment )
      else
        bind_by_position( parameters, environment, to_environment )
      end
    end

    def bind_by_position( parameters, environment, to_env )
      parameters.each_with_index do |p,i|
        if arg = list[i]
          to_env.bind( p.name, arg.evaluate( environment ) )
        elsif p.default?
          to_env.bind( p.name, p.default.evaluate( environment ) )
        else
          raise "Wrong number of arguments #{self} for #{parameters}"
        end
      end
    end

    def by_position?
      ! by_name?
    end

    def bind_by_name( parameters, environment, to_env )
      parameters.each do |p,i|
        if arg = list.find { |pair| p.name === pair.left.value }
          to_env.bind( p.name, arg.right.evaluate( environment ) )
        elsif p.default?
          to_env.bind( p.name, p.default.evaluate( environment ) )
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

