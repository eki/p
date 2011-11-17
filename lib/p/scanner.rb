
module P

  class Scanner
    include Enumerable

    attr_reader   :source, :last_token, :scanner
    attr_accessor :position, :line, :character, :indent

    def initialize( source, position=0, line=1, character=0 )
      @source, @position, @line, @character = source, position, line, character

      @scanner = StringScanner.new( source )
      @scanner.pos = position
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

    def unscan
      scanner.unscan
    end

    def rename_last_token( context )
      rule = rules_for( context ).find do |r| 
        last_token =~ /^#{r[:regexp]}$/
      end

      if rule && ! (rule[:name] === last_token)
        last_token.rename( rule[:name] )
      end 
    end

    def to_a
      ary = []
      ary << next_token until eos?
      ary
    end

    def next_token( context )
      return nil  if eos?

      token = nil

      until token || scanner.eos?
        rules_for( context ).any? do |r|
          if (! r[:empty] || last_token.nil?) && m = scanner.scan( r[:regexp] )
            if g = r[:indent]
              @indent = scanner[g].length
            end

            unless r[:nop]
              token = Token.new( r[:name], m, position, line, character, 
                indent )
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
          @last_token = Token.new( :start, '', position, line, character, 0 )
        else
          @last_token = Token.new( :end, '', position, line, character, -1 )
        end
      end
    end

    def rules_for( context )
      self.class.rules[context] || self.class.rules[:default]
    end

    def self.rules
      @rules ||= {}
    end

    def self.context( name=nil )
      if block_given? && name
        old, @context = @context, name
        yield
        @context = old
      else
        @context || :default
      end
    end

    def self.add( name, regexp, opts={} )
      rules[context] ||= []
      rules[context] << opts.merge( name: name, regexp: regexp )
    end

    def inspect
      "<Scanner last: #{last_token}, position: #{position}/#{source.length}>"
    end

    def to_s
      inspect
    end

    context( :default ) do
      add( :start,              /( *\n)*( *)/m,   empty: true, indent: 2 )
      add( :nil,                /nil/                                    )
      add( :true,               /true/,                                  )
      add( :false,              /false/,                                 )
      add( :number,             /\d+(\.\d+)?f?/,                         )

      add( :semicolon,          /;/,                                     )

      add( :comment,            /[\n ]*(#[^\n]*\n)*#[^\n]*/,   nop: true )
      add( :newline,            /[\n ]*\n( *)/m,               indent: 1 )

      add( :if,                 /if/,                                    )
      add( :unless,             /unless/,                                )
      add( :else,               /else/,                                  )
      add( :while,              /while/,                                 )
      add( :until,              /until/,                                 )
      add( :fn,                 /->/,                                    )
      add( :return,             /return/,                                )

      add( :hash,               /=>/,                                    )

      add( :comp,               /[<][=][>]/,                             )

      add( :or_assign,          /[|][|][=]/,                             )
      add( :and_assign,         /[&][&][=]/,                             )

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

      add( :add_assign,         /[+][=]/,                                )
      add( :sub_assign,         /[-][=]/,                                )
      add( :mult_assign,        /[*][=]/,                                )
      add( :div_assign,         /\/[=]/,                                 )
      add( :modulo_assign,      /[%][=]/,                                )
      add( :bor_assign,         /[|][=]/,                                )
      add( :xor_assign,         /\^[=]/,                                 )
      add( :band_assign,        /[&][=]/,                                )
      add( :bnot_assign,        /[~][=]/,                                )

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

      add( :triple_colon,       /:::/,                                   )
      add( :double_colon,       /::/,                                    )

      add( :question,           /[?]/,                                   )
      add( :colon,              /:/,                                     )

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

      add( :whitespace,         / +/,                          nop: true )
    end

    context( :dot ) do
      add( :id,                 /[@a-zA-Z_][\w]*[?]?/)

      add( :id,                 /[<][=][>]/          )  # :comp

      add( :id,                 /[*][*]/             )  # :exp

      add( :id,                 /\[\]=/              )  # array indexing (set)
      add( :id,                 /\[\]/               )  # array indexing (get)

      add( :id,                 /[>][=]/             )  # :gte
      add( :id,                 /[<][=]/             )  # :lte
      add( :id,                 /[=][=]/             )  # :eq

      add( :id,                 /[<][<]/             )  # :lshift
      add( :id,                 /[>][>]/             )  # :rshift

      add( :id,                 /[+]/                )  # :add
      add( :id,                 /[-]/                )  # :sub
      add( :id,                 /[*]/                )  # :mult
      add( :id,                 /\//                 )  # :div
      add( :id,                 /[%]/                )  # :modulo

      add( :id,                 /[>]/                )  # :gt
      add( :id,                 /[<]/                )  # :lt
      add( :id,                 /[&]/                )  # :band
      add( :id,                 /[|]/                )  # :bor
      add( :id,                 /\^/                 )  # :xor

      add( :whitespace,         / +/,                          nop: true )
    end

    context( :double_quote ) do
      add( :double_quote,       /"/,                                     )
      add( :esc_newline,        /\\n/,                                   )
      add( :esc_backslash,      /\\\\/,                                  )
      add( :esc_tab,            /\\t/,                                   )
      add( :esc_other,          /\\./,                                   )
      add( :open_interp,        /[#][{]/,                                )
      add( :character,          /./,                                     )
    end

    context( :single_quote ) do
      add( :single_quote,       /'/,                                     )
      add( :esc_single_quote,   /\\'/,                                   )
      add( :esc_backslash,      /\\\\/,                                  )
      add( :character,          /./,                                     )
    end

    context( :single_colon ) do
      add( :whitespace,         /\s/,                                    )
      add( :close,              /[)}\],\.]/,                             )
      add( :character,          /./,                                     )
    end

    context( :double_colon ) do
      add( :close,              /[\n ]*\n( *)/m,               indent: 1 )
      add( :whitespace,         /\s/,                                    )
      add( :open_interp,        /[#][{]/,                                )
      add( :character,          /./,                                     )
    end

    context( :triple_colon ) do
      add( :newline,            /[\n ]*\n( *)/m,               indent: 1 )
      add( :whitespace,         /\s/,                                    )
      add( :open_interp,        /[#][{]/,                                )
      add( :character,          /./,                                     )
    end
  end
end

