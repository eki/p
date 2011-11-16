
module P

  class MapExpr < Atom

    def initialize( value={} )
      @value = value
    end

    def evaluate( environment )
      if empty?
        evaluate_as_empty( environment )
      elsif map?
        evaluate_as_map( environment )
      elsif set?
        evaluate_as_set( environment )
      else
        raise "Malformed map / hash / set #{value}"
      end
    end

    def evaluate_as_empty( environment )
      evaluate_as_map( environment )  # temporary
    end

    def evaluate_as_map( environment )
      h = {}
      value.each do |expr| 
        if expr.pair?
          h[P.string( expr.left )] = expr.right.evaluate( environment )
        else
          raise "Expected pair (#{expr}) in map: #{value}"
        end
      end

      P.map( h )
    end

    def evaluate_as_set( environment )
      P.set( value.map { |e| e.evaluate( environment ) } )
    end

    def empty?
      value.empty?
    end

    def map?
      value.all? { |expr| expr.pair? }
    end

    def set?
      ! value.any? { |expr| expr.pair? }
    end

    def to_s
      inspect
    end

    def inspect
      s = value.map do |expr|
        if expr.pair?
          "#{expr.left}: #{expr.right}"
        else
          raise "Expected pair (#{expr}) in map: #{value}"
        end
      end.join( ', ' )

      "(map #{s})"
    end
  end

end

