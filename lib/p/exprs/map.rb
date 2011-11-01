
module P

  class MapExpr < Atom

    def initialize( value )
      @value = value
    end

    def evaluate( environment )
      h = {}
      value.each do |expr| 
        if expr.pair?
          h[P.string( expr.left )] = expr.right.evaluate( environment )
        else
          raise "Expected pair (#{expr}) in map: #{value}"
        end
      end

      Map.new( h )
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

