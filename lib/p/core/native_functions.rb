
module P

  class NF < Object
    receive( :puts, 'o' ) do |env|
      puts( env[:o].r_send( :to_string ) )
      P.nil
    end

    receive( :default_to_string ) { |env| P.string( 'Object' ) }
    receive( :default_inspect )   { |env| P.string( 'Object' ) }

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

