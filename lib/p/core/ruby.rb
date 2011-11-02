
class String;     def to_p;   P.string( self );    end; end
class Symbol;     def to_p;   P.string( self );    end; end
class Numeric;    def to_p;   P.number( self );    end; end
class TrueClass;  def to_p;   P.true;              end; end
class FalseClass; def to_p;   P.false;             end; end
class NilClass;   def to_p;   P.nil;               end; end

class Array
  def to_p
    P.list( *map { |v| v.to_p } )
  end
end

class Hash
  def to_p
    h = {}
    each { |k,v| h[k.to_p] = v.to_p }
    P.map( h )
  end
end

class Object
  def to_p
    raise "Undefined to_p for #{self}:#{self.class}"
  end
end

