
module P

  class Scanner
    include Enumerable

    attr_reader   :source, :last_token
    attr_accessor :position, :line, :character, :indent

    def initialize( source, position=0, line=0, character=0 )
      @source, @position, @line, @character = source, position, line, character
    end

    def eos?
      last_token && last_token === :end
    end

    def each
      if block_given?
        yield( next_token )  until eos?
      else
        to_a
      end
    end

    def to_a
      ary = []
      ary << next_token until eos?
      ary
    end

    def next_token
      return nil  if eos?

      scanner = StringScanner.new( source )
      scanner.pos = position

      token = nil

      until token || scanner.eos?
        rules.any? do |r|
          if (! r[:empty] || last_token.nil?) && m = scanner.scan( r[:regexp] )
            if g = r[:indent]
              @indent = scanner[g].length
            end

            unless r[:nop]
              token = Token.new( r[:name], m, line, character, indent )
            end

            if r[:indent]
              @line += m.count( "\n" )
              @character = indent
            else
              @character += m.length
            end
          end
        end or raise "Invalid input #{line}:#{character} in #{source}"
      end

      if token
        @position = scanner.pos

        @last_token = token
      else
        if last_token.nil?
          @last_token = Token.new( :start, '', line, character, 0 )
        else
          @last_token = Token.new( :end, '', line, character, -1 )
        end 
      end
    end

    def rules
      self.class.rules
    end

    def self.rules
      @rules ||= []
    end

    def self.add( name, regexp, opts={} )
      self.rules << opts.merge( name: name, regexp: regexp )
    end

    def inspect
      "<Scanner last: #{last_token}, position: #{position}/#{source.length}>"
    end

    def to_s
      inspect
    end
  end

  class CodeScanner < Scanner
    add( :start,              /( *\n)*( *)/m,   empty: true, indent: 2 )
    add( :nil,                /nil/                                    )
    add( :true,               /true/,                                  )
    add( :false,              /false/,                                 )
    add( :number,             /\d+(\.\d+)?/,                           )

    add( :semicolon,          /;/,                                     )
    add( :newline,            /[\n ]*\n( *)/m,               indent: 1 )

    add( :if,                 /if/,                                    )
    add( :unless,             /unless/,                                )
    add( :else,               /else/,                                  )
    add( :while,              /while/,                                 )
    add( :until,              /until/,                                 )
    add( :fn,                 /->/,                                    )

    add( :comp,               /[<][=][>]/,                             )

    add( :exp,                /[*][*]/,                                )
    add( :single_assign,      /[:][=]/,                                )
    add( :gte,                /[>][=]/,                                )
    add( :lte,                /[<][=]/,                                )
    add( :eq,                 /[=][=]/,                                )
    add( :neq,                /[!][=]/,                                )
    add( :and,                /[&][&]/,                                )
    add( :or,                 /[|][|]/,                                )
    add( :lshift,             /[<][<]/,                                )
    add( :rshift,             /[>][>]/,                                )
    add( :interp,             /[#][{]/,                                )

    add( :add_assign,         /[+][=]/,                                )
    add( :sub_assign,         /[-][=]/,                                )
    add( :mult_assign,        /[*][=]/,                                )
    add( :div_assign,         /\/[=]/,                                 )
    add( :modulo_assign,      /[%][=]/,                                )
    add( :bor_assign,         /[|][=]/,                                )
    add( :xor_assign,         /\^[=]/,                                 )
    add( :band_assign,        /[&][=]/,                                )
    add( :bnot_assign,        /[~][=]/,                                )

    add( :or_assign,          /[|][|][=]/,                             )
    add( :and_assign,         /[&][&][=]/,                             )

    add( :add,                /[+]/,                                   )
    add( :sub,                /[-]/,                                   )
    add( :mult,               /[*]/,                                   )
    add( :div,                /\//,                                    )
    add( :modulo,             /[%]/,                                   )

    add( :assign,             /[=]/,                                   )

    add( :gt,                 /[>]/,                                   )
    add( :lt,                 /[<]/,                                   )
    add( :not,                /[!]/,                                   )
    add( :bnot,               /[~]/,                                   )
    add( :band,               /[&]/,                                   )
    add( :bor,                /[|]/,                                   )
    add( :xor,                /\^/,                                    )

    add( :question,           /[?]/,                                   )
    add( :colon,              /[:]/,                                   )

    add( :dot,                /[.]/,                                   )
    add( :comma,              /[,]/,                                   )

    add( :open_paren,         /\(/,                                    )
    add( :close_paren,        /\)/,                                    )

    add( :open_curly,         /\{/,                                    )
    add( :close_curly,        /\}/,                                    )

    add( :open_square,        /\[/,                                    )
    add( :close_square,       /\]/,                                    )

    add( :double_quote,       /"/,                                     )
    add( :single_quote,       /'/,                                     )
    add( :backtick,           /`/,                                     )

    add( :id,                 /[@a-zA-Z_][\w]*[?]?/,                   )

    add( :comment,            /#\W[^\n]*/,                             )

    add( :whitespace,         / +/,                          nop: true )
  end

end

