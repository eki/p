
module P

  class NF < Object
    receive( :puts, 'args: *' ) do |env|
      env[:args].r_send( :each, 
        NativeFunction.new( 'v' ) { |e2| puts e2[:v].r_send( :to_string ) } )

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

    receive( :require, 'path, environment: ?' ) do |env|
      fname = "/home/eki/projects/p/p_lib/#{env[:path]}.p"
      if File.file?( fname )
        c = open( fname, 'r' ).read
        tree = P.parse( c )
        exec_env = Environment.new
        o = tree.evaluate( exec_env )

        if P.true?( ae = env[:environment] )
          exec_env.bindings.each do |b|
            unless ae.defined?( b.name )
              if b.mutable?
                ae.set( b.name, b.value )
              else
                ae.bind( b.name, b.value )
              end
            end
          end
        end

        o
      end 
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

