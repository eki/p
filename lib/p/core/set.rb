
require 'set'

module P

  class Set < Object
    include Enumerable

    attr_reader :value

    def initialize( ary )
      @value = ::Set.new( ary )
    end

    def empty?
      value.empty?
    end

    def length
      value.length
    end

    def []( key )
      value[key]
    end

    def each( &block )
      value.each( &block )
    end

    receive( :set?,      %q( () -> true ) )

    receive( :to_set     ) { |env| self }
    receive( :empty?     ) { |env| empty? }
    receive( :length     ) { |env| length }
    receive( :to_literal ) { |env| to_literal }
    receive( :to_string  ) { |env| to_literal }

    receive( :each, 'fn' ) do |env|
      fn = env[:fn]
      arity = fn.r_send( :arity ).r_send( :to_integer ).to_int

      if arity == 1
        value.each { |k,v| fn.r_call( v ) }
      else
        raise "Each expected fn to take 1 arg."
      end
    end

    def to_s
      to_literal
    end

    def to_literal
      "{#{map { |v| v.to_s }.join( ', ' )}}"
    end

    def inspect
      to_literal
    end
  end

  def self.set( ary=[] )
    Set.new( ary )
  end

end

