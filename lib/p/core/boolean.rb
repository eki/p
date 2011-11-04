
module P

  def self.boolean( v )
    if v.to_s == 'true'
      P.true
    else
      P.false
    end
  end

  def self.true?( v )
    ! (v == P.nil || v == P.false)
  end

  def self.false?( v )
    ! true?( v )
  end

  def self.true
    @true ||= Object.build do
      bind( 'to_literal', %q( () -> 'true' ) )
    end
  end

  def self.false
    @false ||= Object.build do
      bind( 'to_literal', %q( () -> 'false' ) )
    end
  end

  def self.nil
    @nil ||= Object.build do
      bind( 'to_string',  %q( () -> '' ) )
      bind( 'to_literal', %q( () -> 'nil' ) )
      bind( :nil?,        %q( () -> true ) )
    end
  end

end

