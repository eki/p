
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
      bind( 'to_string', %Q( () -> 'true' ) )

      bind( '==', fn( '(o)' ) { |env| P.boolean( env[:o] == P.true ) } )
    end
  end

  def self.false
    @false ||= Object.build do
      bind( 'to_string', %Q( () -> 'false' ) )

      bind( '==', fn( '(o)' ) { |env| P.boolean( env[:o] == P.false ) } )
    end
  end

  def self.nil
    @nil ||= Object.build do
      bind( 'to_string',  %Q( () -> '' ) )
      bind( 'to_literal', %Q( () -> 'nil' ) )

      bind( '==', fn( '(o)' ) { |env| P.boolean( env[:o] == P.nil ) } )
    end
  end

end

