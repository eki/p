
require 'strscan'

require 'p/scanner'
require 'p/token'
require 'p/expr'
require 'p/parser'

module P

  def self.scan( source )
    Scanner.scan( source )
  end

  def self.parse( source )
    Parser.new( Scanner.scan( source ) ).parse
  end

end

