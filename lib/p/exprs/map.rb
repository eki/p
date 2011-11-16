
module P

  class MapExpr < Atom

    def initialize( value={} )
      @value = value
    end

    def evaluate( environment )
      if empty?
        evaluate_as_empty( environment )
      elsif trie?
        evaluate_as_trie( environment )
      elsif hash?
        evaluate_as_hash( environment )
      elsif set?
        evaluate_as_set( environment )
      else
        raise "Malformed trie / hash / set #{value}"
      end
    end

    def evaluate_as_empty( environment )
      P.empty_map
    end

    def evaluate_as_trie( environment )
      h = {}
      value.each do |expr| 
        if expr.pair?
          h[P.string( expr.left )] = expr.right.evaluate( environment )
        else
          raise "Expected pair (#{expr}) in map: #{value}"
        end
      end

      P.trie( h )
    end

    def evaluate_as_hash( environment )
      h = {}
      value.each do |expr| 
        if expr.pair?
          h[P.string( expr.left )] = expr.right.evaluate( environment )
        elsif expr.hash_pair?
          h[expr.left.evaluate( environment )] = 
            expr.right.evaluate( environment )
        else
          raise "Expected pair or hash_pair (#{expr}) in map: #{value}"
        end
      end

      P.hash( h )
    end

    def evaluate_as_set( environment )
      P.set( value.map { |e| e.evaluate( environment ) } )
    end

    def empty?
      value.empty?
    end

    def hash?
      value.all? { |expr| expr.pair? || expr.hash_pair? }
    end

    def trie?
      value.all? { |expr| expr.pair? }
    end

    def set?
      value.all? { |expr| ! (expr.pair? || expr.hash_pair?) }
    end

    def to_s
      inspect
    end

    def inspect
      s = value.map do |expr|
        if expr.pair?
          "#{expr.left}: #{expr.right}"
        elsif expr.hash_pair?
          "#{expr.left} => #{expr.right}"
        else
          raise "Expected pair (#{expr}) in map: #{value}"
        end
      end.join( ', ' )

      "(map #{s})"
    end
  end

end

