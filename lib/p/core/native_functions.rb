
module P

  class NF < Object
    receive( :puts, 'o' ) do |env|
      puts( env[:o].r_send( :to_string ) )
      P.nil
    end

    receive( :inspect, 'o' ) do |env|
      o = env[:o]

      if P.true?( o.r_send( :respond_to?, :inspect ) )
        list = o.r_send( :inspect ).r_send( :to_list )

        s = list.map do |m|
          "#{m}: #{o.r_send( m.to_sym )}"
        end.join( ', ' )

        P.string( "(#{s})" )
      elsif P.true?( o.r_send( :respond_to?, :to_literal ) )
        o.r_send( :to_literal )
      else
        o.r_send( :to_string )
      end
    end

    receive( :default_to_string ) { |env| P.string( 'Object' ) }
    receive( :default_inspect )   { |env| P.list( P.string( :to_string ) ) }

    receive( :new, 'f' ) do |env|
      f = env[:f]

      e = Environment.new
      f.r_eval( [], e )       # e will contain the bindings created by f

      unless e.bindings.any? { |b| b.name == :to_string }
        e.bind( :to_string, P.nf( :default_to_string ) )
      end

      unless e.bindings.any? { |b| b.name == :inspect }
        e.bind( :inspect, P.nf( :default_inspect ) )
      end

      Object.new( prototype: P.object, bindings: e.bindings )
    end

    def []( name )
      _get( name )
    end
  end

  def self.nf( name )
    @nf ||= NF.new( prototype: nil )
    @nf[name.to_sym]
  end

end

