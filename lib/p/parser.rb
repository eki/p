
module P

  class Rule
    include Comparable

    attr_reader :name, :precedence, :associativity, :opts, :block

    def initialize( name=nil, prec=0, assoc=:left, opts={}, &block )
      @name, @precedence, @associativity, @opts, @block = 
        name, prec, assoc, opts, block
    end

    def exec( parser, *rest )
      args = *rest[0..(block.arity)]

      parser.instance_exec( *args, &block )
    end

    def block?
      opts[:block]
    end

    def right_optional?
      opts[:right_optional]
    end

    def <=>( r )
      p, rp = precedence, r.precedence

      if rp == '*' && p != '*'
        rp = p - 2
      elsif rp != '*' && p == '*'
        p  = rp + 2
      elsif rp == '*' && p == '*'
        rp, p = 0, 0
      end

      rp = rp - (r.associativity == :right ? 1 : 0)

      p <=> rp
    end

    def inspect
      "<Rule #{name} #{precedence} #{associativity} #{opts}>"
    end

    def to_s
      inspect
    end
  end

  class RuleSet
    attr_reader :set

    def initialize( &block )
      @set = { value: {}, infix: {}, prefix: {}, line_separator: {} }

      instance_eval( &block )
    end

    def for( table, name )
      h = set[table] || {}
      h[name.to_sym]
    end

    def value( name, &block )
      block ||= lambda { |t| Atom.new( t.name, t ) }
      set[:value][name] = Rule.new( name, &block )
    end

    def infix( name, prec, assoc=:left, opts={}, &block )
      block ||= lambda { |t,left,right| Expr.new( t.name, left, right ) }
      set[:infix][name] = Rule.new( name, prec, assoc, opts, &block )
    end

    def assign( opts={} )
      prec  = opts[:precedence]    || 3
      assoc = opts[:associativity] || :right
      name  = opts[:name]          || :assign

      if op = opts.delete( :op )
        infix( :"#{op}_#{name}", prec, assoc, opts ) do |t, left, right|
          Expr.new( name, left, Expr.new( op, left, right ) )
        end
      else
        infix( name, prec, assoc, opts ) do |t, left, right|
          Expr.new( name, left, right )
        end
      end
    end

    def prefix( name, prec=0, assoc=:left, opts={}, &block )
      op = opts.delete( :op )
      block ||= lambda do |t|
        Expr.new( op || t.name, 
          parse_expression( nil, Rule.new( name, prec, assoc, opts ) ) )
      end

      set[:prefix][name] = Rule.new( name, &block )
    end

    def line_separator( name )
      set[:line_separator][name] = Rule.new( name ) { |t| true }
    end
  end

  class UnexpectedEndError < StandardError
    def initialize( message="Unexpected end of input." )
      super( message )
    end
  end

  class Parser
    attr_reader :source, :scanner

    def initialize( source )
      @source = source
      @scanner = CodeScanner.new( source )
      @scanner.next_token
    end

    def parse
      program = parse_program

      unless consume( :end )
        if scanner.eos?
          raise "Unexpected end of input"
        else
          raise "Unexpected token: #{scanner.last_token}"
        end
      end

      program
    end

    def parse_program
      if consume( :start )
        blocks = []
        blocks << parse_block  until top === :end

        if blocks.length > 1
          Expr.new( :program, Expr.new( :block, *blocks ) )
        else
          Expr.new( :program, blocks.first )
        end
      else
        raise "Missing start token!"
      end
    end

    def parse_block( min_indent=nil )
      return false  if min_indent && top.indent <= min_indent

      indent = top.indent

      block = [:block, parse_line]

      while parse_line_separator
        if top.indent == indent
          block << parse_line
        elsif top.indent < indent
          return Expr.new( *block )
        elsif top.indent > indent
          block << parse_block
        end
      end

      Expr.new( *block )
    end

    def parse_line
      expr  = parse_expression
      expr2 = parse_expression( expr )
      expr2 || expr
    end

    def parse_expression( expr=nil, rule=nil )
      value = expr || parse_rule( :prefix ) || parse_rule( :value ) ||
        parse_interpolated_string || parse_uninterpolated_string

      unless value
        if top === :end
          raise UnexpectedEndError.new
        else
          raise "Unexpected token: #{top.name}:#{top}"
        end
      end

      while infix = parse_infix( value, rule )
        value = infix
      end

      value
    end

    def parse_line_separator
      parse_rule( :line_separator )
    end

    def parse_rule( table, *rest )
      t = top
      rule = RULES.for( table, t )

      if rule && (! block_given? || yield( t ))
        rule.exec( self, consume( top ), *rest )
      end
    end

    def parse_else( indent )
      if top === :else && top.indent == indent
        consume( :else )
        if parse_line_separator
          parse_block( indent )  or raise "Else without properly indented block"
        elsif e = parse_expression
          Expr.new( :block, e )
        end
      end
    end

    def parse_infix( left, rule=nil )
      return false  unless left

      r = RULES.for( :infix, top )

      if r && (! rule || r > rule)
        t = consume( top )

        if r.block? && top === :newline && parse_line_separator
           right = parse_block( t.indent )
        else
          consume( :newline )
          right = parse_expression( nil, r )
        end

        unless right || r.right_optional?
          raise "Infix operator without right side!"
        end

        r.exec( self, t, left, right )
      end
    end

    def parse_statement( statement, token )
      if condition = parse_expression
        if top === :newline && parse_line_separator
          if block = parse_block( token.indent )
            if block_given?
              yield( token, condition, block )
            else
              Expr.new( token.name, condition, block )
            end
          else
            raise "Error: #{statement} statement without block"
          end
        else
          raise "Error: expected newline or semicolon"
        end
      else
        raise "Error: #{statement} statement without condition"
      end
    end

    def parse_interpolated_string
      return false  unless top === :double_quote

      s, ary = '', []
      ss = InterpolatedStringScanner.new( source, scanner.position )

      while t = ss.next_token
        case
          when t === :double_quote
            ary << Atom.new( :string, s )  unless s.empty?
            @scanner.position = ss.position
            break
          when t === :esc_newline
            s << "\n"
          when t === :esc_backslash
            s << "\\"
          when t === :esc_tab
            s << "\t"
          when t === :esc_other
            s << t.value[1..2]
          when t === :open_interp
            ary << Atom.new( :string, s )  unless s.empty?

            scanner.position = ss.position
            scanner.next_token

            ary << parse_expression

            unless top === :close_curly
              raise "Expected end of string interpolation!"
            end
            
            ss.position = scanner.position
            s = ''
          when t === :close_interp
            raise "Error: close_interp should have been scanned by CodeScanner"
          when t === :character
            s << t.value

          else raise "Unexpected token in interpolated string: #{t.name}:#{t}"
        end
      end

      scanner.position = ss.position
      scanner.next_token

      consume( :double_quote )

      Expr.new( :interp_string, *ary )
    end

    def parse_uninterpolated_string
      return false  unless top === :single_quote

      s = ''
      ss = UninterpolatedStringScanner.new( source, scanner.position )

      while t = ss.next_token
        case
          when t === :single_quote
            @scanner.position = ss.position
            break
          when t === :esc_single_quote
            s << "'"
          when t === :esc_backslash
            s << "\\"
          when t === :character
            s << t.value

          else raise "Unexpected token in uninterpolated string: #{t.name}:#{t}"
        end
      end

      scanner.position = ss.position
      scanner.next_token

      consume( :single_quote )

      Atom.new( :string, s )
    end

    def consume( token )
      if top === token
        scanner.next_token
        token
      end
    end

    def top
      scanner.last_token
    end

    def seq_to_params( seq )
      if seq.seq?
        Expr.new( :params, *seq.flatten.list )
      else
        Expr.new( :params, seq )
      end
    end

    def seq_to_args( seq )
      if seq.seq?
        s = seq.flatten
      else
        s = Expr.new( :seq, seq )
      end

      if bad = s.list.find { |v| ! v.id? }
        raise "Arg list may only contain ids: #{s}:#{bad}"
      end

      Expr.new( :args, *s.list )
    end

    def params_to_args( params )
      if bad = params.find { |v| ! v.id? }
        raise "Arg list may only contain ids: #{s}:#{bad}"
      end

      Expr.new( :args, *params.list )
    end


    RULES = RuleSet.new do
      value( :number )
      value( :id )
      value( :true )
      value( :false )
      value( :nil )

      value( :mult ) { |t| Atom.new( :glob, t ) }
      value( :exp )  { |t| Atom.new( :double_glob, t ) }

      infix( :if,     2 ) { |t,left,right| Expr.new( :cif, left, right ) }
      infix( :unless, 2 ) { |t,left,right| Expr.new( :cun, left, right ) }

      infix( :while,  2 ) { |t,left,right| Expr.new( :cwhile, left, right ) }
      infix( :until,  2 ) { |t,left,right| Expr.new( :cuntil, left, right ) }

      assign( name: :assign )
      assign( name: :single_assign )

      assign( op: :add    )
      assign( op: :sub    )
      assign( op: :mult   )
      assign( op: :div    )
      assign( op: :and    )
      assign( op: :or     )
      assign( op: :modulo )
      assign( op: :bor    )
      assign( op: :xor    )
      assign( op: :band   )
      assign( op: :bnot   )

      infix( :fn, '*', :right, block: true ) do |t,left,right|
        right = Expr.new( :block, right ) unless right.block?

        Expr.new( :fn, seq_to_args( left ), right )
      end

      infix( :comma, 5 ) { |t,left,right| Expr.new( :seq, left, right ) }

      infix( :colon, 6 ) do |t,left,right|
        if left.atom?
          Expr.new( :pair, Expr.new( :symbol, left ), right )
        elsif left.symbol?
          Expr.new( :pair, left, right )
        else
          raise "Expected left side of pair to be symbol, got #{left}"
        end
      end

      infix( :question, 7 ) do |t,left,right|
        if consume( :colon )
          if e = parse_expression( nil, Rule.new( :eif, 4 ) )
            Expr.new( :if, left, right, e )
          else
            raise "Couldn't find else conditional to complete ?:"
          end
        else
          raise "Expected : to complete ?:"
        end
      end

      infix( :bor,     8 )
      infix( :xor,     9 )
      infix( :band,   10 )

      infix( :and,    11 )
      infix( :or,     11 )

      infix( :eq,     12 )
      infix( :neq,    12 )
      infix( :gt,     12 )
      infix( :lt,     12 )
      infix( :gte,    12 )
      infix( :lte,    12 )

      infix( :comp,   13 )

      infix( :lshift, 14 )
      infix( :rshift, 14 )
      
      infix( :add,    15 )
      infix( :sub,    15 )

      infix( :mult,   16 )
      infix( :div,    16 )
      infix( :modulo, 16 )

      infix( :exp,    17 ) 

      infix( :open_paren, '*', :right, right_optional: true ) do |t,left,right|
        unless left.id? || left.fn? || left.call?
          raise "Function calls require id or fn or call, not #{left}"
        end

        raise "Expected ) got #{t}"  unless consume( :close_paren )

        if right
          Expr.new( :call, left, seq_to_params( right ) )
        else
          Expr.new( :call, left, Expr.new( :params ) )
        end
      end

      prefix( :open_paren ) do |t|
        expr = parse_expression
        expr = parse_expression( expr )  while consume( :newline )

        raise "Expected ) got #{t}"  unless consume( :close_paren )

        expr || Expr.new( :seq )
      end

      prefix( :open_curly ) do |t|
        expr = parse_expression
        expr = parse_expression( expr ) while consume( :newline )

        raise "Expected } got #{t}"  unless consume( :close_curly )

        Expr.new( :map, *(expr || Expr.new( :seq )).flatten.list )
      end

      prefix( :open_square ) do |t|
        expr = parse_expression
        expr = parse_expression( expr ) while consume( :newline )

        raise "Expected ] got #{t}"  unless consume( :close_square )

        Expr.new( :list, *(expr || Expr.new( :seq )).flatten.list )
      end

      prefix( :div ) do |t|
        s = ""

        until consume( :div )
          raise "Unterminated regex"  if top === :end

          s << consume( top ).value
        end

        Atom.new( :regex, s )
      end

      prefix( :fn ) do |t|
        if top === :newline && parse_line_separator
          Expr.new( :fn, Expr.new( :args ), parse_block( t.indent ) )
        elsif expr = parse_expression
          expr = parse_expression  while expr && consume( :newline )
          Expr.new( :fn, Expr.new( :args ), Expr.new( :block, expr ) )
        else
          Expr.new( :fn, Expr.new( :args ), Expr.new( :block ) )
        end
      end

      prefix( :not,  18 )
      prefix( :bnot, 18 )

      infix( :not, 19, :right, right_optional: true ) do |t,left,right|
        if right
          raise "Unexpected #{right}"
        end

        Expr.new( :send, left, Expr.new( :id, '!' ), Expr.new( :params ))
      end

      infix( :dot, 19 ) do |t,left,right|
        unless right.id? || right.call?
          raise "Expected #{left}.id got #{right}"
        end

        if right.call?
          Expr.new( :send, left, *right.list )
        else
          Expr.new( :send, left, right, Expr.new( :params ) )
        end
      end

      prefix( :sub,   20, op: :neg )

      prefix( :colon, 20 ) do |t|
        if value = parse_rule( :value )
          Expr.new( :symbol, value )
        else
          raise "Expected symbol"
        end
      end

      prefix( :if ) do |t|
        parse_statement( :if, t ) do |t, condition, block|
          if e = parse_else( t.indent )
            Expr.new( :if, condition, block, e )
          else
            Expr.new( :if, condition, block )
          end
        end
      end

      prefix( :unless ) do |t|
        parse_statement( :unless, t ) do |t,condition,block|
          Expr.new( :unless, condition, block )
        end
      end

      prefix( :while ) { |t| parse_statement( :while, t ) }
      prefix( :until ) { |t| parse_statement( :until, t ) }

      line_separator( :newline )
      line_separator( :semicolon )
      line_separator( :start )
    end
  end

end

