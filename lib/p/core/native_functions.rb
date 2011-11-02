
module P

  class NF < Object
    receive( :puts, 'args: *' ) do |env|
      env[:args].each do |arg|
        puts( arg.r_send( :to_string ) )
      end

      P.nil
    end

    receive( :inspect, 'o' ) do |env|
      o = env[:o]

      if P.true?( o.r_send( :respond_to?, :inspect ) )
        list = o.r_send( :inspect ).r_send( :to_list )

        s = list.map { |m| "#{m}: #{o.r_send( m )}" }.join( ', ' )

        "(#{s})"
      elsif P.true?( o.r_send( :respond_to?, :to_literal ) )
        o.r_send( :to_literal )
      else
        o.r_send( :to_string )
      end
    end

    receive( :new, 'f' ) do |env|
      P.object.r_send( :clone, env[:f] )
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

