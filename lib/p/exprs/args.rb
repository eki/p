
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
        if p.glob?
          last_args = list[parameters.length - 1, list.length] || []
          e_args = last_args.map { |a| a.evaluate( environment ) }
          to_env.bind( p.name, e_args.to_p )
        elsif arg = list[i]
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
        if p.glob?
          last_args = list.to_a[parameters.length - 1, list.length] || []
          e_args = last_args.map do |pair|
            [pair.left.to_p, pair.right.evaluate( environment )]
          end

          to_env.bind( p.name, Hash[e_args].to_p )
        elsif arg = list.find { |pair| p.name === pair.left.to_sym }
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

