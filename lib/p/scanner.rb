
module P

  module Scanner

    def self.scan( source )
      indent, tokens, line, character = nil, [], 0, 0

      scanner = StringScanner.new( source )

      until scanner.eos?
        RULES.any? do |r|
          if (! r[:empty] || tokens.empty?) && m = scanner.scan( r[:regexp] )
            if g = r[:indent]
              indent = scanner[g].length
            end

            unless r[:nop]
              tokens << Token.new( r[:name], m, line, character, indent )
            end

            if r[:indent]
              line += m.count( "\n" )
              character = indent
            else
              character += m.length
            end
          end
        end or raise "Invalid input #{line}:#{character} in #{source}"
      end

      if tokens.empty?
        tokens << Token.new( :start, '', 0, 0, 0 )
      elsif tokens.last === :newline
        tokens.pop
      end

      tokens << Token.new( :end, '', line, character, 0 )

      tokens
    end

    RULES = []

    def self.add( name, regexp, opts={} )
      RULES << opts.merge( name: name, regexp: regexp )
    end

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

    add( :double_string,      /"[^\"]*"/m,                             )
    add( :single_string,      /'[^\']*'/m,                             )
    add( :backtick_string,    /`[^\`]*`/m,                             )

    add( :id,                 /[@a-zA-Z_][\w]*[?]?/,                   )

    add( :comment,            /#\W[^\n]*/,                             )

    add( :whitespace,         / +/,                          nop: true )

  end
end

