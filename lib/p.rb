
require 'strscan'

require 'p/scanner'
require 'p/token'
require 'p/expr'
require 'p/parser'

Dir.glob( File.expand_path( File.dirname( __FILE__ ) ) + "/p/exprs/*.rb" ) do |f|
  require f.to_s
end

require 'p/core/object'

Dir.glob( File.expand_path( File.dirname( __FILE__ ) ) + "/p/core/*.rb" ) do |f|
  require f.to_s
end

module P

  def self.scan( source )
    CodeScanner.new( source ).to_a
  end

  def self.iscan( source )
    InterpolatedStringScanner.new( source, 1 ).to_a
  end

  def self.parse( source )
    Parser.new( source ).parse
  end

  def self.eval( source, environment=Environment.top )
    Parser.new( source ).parse.evaluate( environment )
  end

end

