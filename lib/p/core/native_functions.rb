
require 'p/core/function'

module P

  FN = {}

  def self.fn( name, args, &block )
    FN[name.to_sym] = NativeFunction.new( args, &block )
  end

  P.fn( :puts, '(obj: ?)' ) do |env|
    s = env.get( 'obj' ).to_s    # should really p_send to_s
    puts( s )
    Nil.new
  end

end

