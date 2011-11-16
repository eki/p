
module P

  def self.empty_map
    @empty_map ||= Object.build do
      bind( 'to_string',  %q( () -> '{}' ) )
      bind( 'to_literal', %q( () -> '{}' ) )
      bind( :empty?,      %q( () -> true ) )
      bind( :map?,        %q( () -> true ) )
      bind( :trie?,       %q( () -> true ) )
      bind( :hash?,       %q( () -> true ) )
      bind( :set?,        %q( () -> true ) )

      bind( :to_map,      fn { |env| self   } )
      bind( :to_trie,     fn { |env| P.trie } )
      bind( :to_hash,     fn { |env| P.hash } )
      bind( :to_set,      fn { |env| P.set  } )
    end
  end

  def self.map( h )
    if h.empty?
      empty_map
    elsif h.all? { |k,v| k.kind_of?( String ) }
      trie( h )
    else
      hash( h )
    end
  end

end

