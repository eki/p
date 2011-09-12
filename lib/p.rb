
require 'strscan'

require 'p/scanner'
require 'p/token'
require 'p/expr'
require 'p/parser'

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

end

