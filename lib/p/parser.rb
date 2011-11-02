
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

    def right_optional
      opts[:right_optional]
    end

    def right_optional?
      !! right_optional
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
      @set = { value: {}, infix: {}, prefix: {}, postfix: {}, 
               line_separator: {} }

      instance_eval( &block )
    end

    def for( table, name )
      h = set[table] || {}
      h[name.to_sym]
    end

    def value( name, &block )
      block ||= lambda { |t| Expr.send( t.name, t ) }
      set[:value][name] = Rule.new( name, &block )
    end

    def infix( name, prec, assoc=:left, opts={}, &block )
      block ||= lambda do |t,left,right| 
        Expr.send( t.name, left, right )
      end
      set[:infix][name] = Rule.new( name, prec, assoc, opts, &block )
    end

    def postfix( name, prec, assoc=:left, opts={}, &block )
      block ||= lambda { |t,left| Expr.send( t.name, left ) }
      set[:postfix][name] = Rule.new( name, prec, assoc, opts, &block )
    end

    def assign( opts={} )
      prec  = opts[:precedence]    || 3
      assoc = opts[:associativity] || :right
      name  = opts[:name]          || :assign

      if op = opts.delete( :op )
        infix( :"#{op}_#{name}", prec, assoc, opts ) do |t, left, right|
          Expr.send( name, left, Expr.send( op, left, right ) )
        end
      else
        infix( name, prec, assoc, opts ) do |t, left, right|
          Expr.send( name, left, right )
        end
      end
    end

    def prefix( name, prec=0, opts={}, &block )
      op = opts.delete( :op )
      block ||= lambda do |t|
        Expr.send( op || t.name, 
          parse_expression( nil, Rule.new( name, prec, :left, opts ) ) )
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

  class NewlineExpectedError < StandardError
    def initialize( message="Expected newline." )
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
          Expr.program( Expr.block( *blocks ) )
        else
          Expr.program( blocks.first )
        end
      else
        raise "Missing start token!"
      end
    end

    def parse_block( min_indent=nil )
      return false  if min_indent && top.indent <= min_indent

      indent = top.indent

      if expr = parse_disjoint
        block = [expr]
      else
        raise "Failed to parse_block at #{top.name}:#{top}"
      end

      while parse_line_separator
        if top.indent == indent
          block << parse_disjoint
        elsif top.indent < indent
          return Expr.block( *block )
        elsif top.indent > indent
          block << parse_block
        end
      end

      Expr.block( *block )
    end

    DISJOINT = {
      number: true,
      id: true,
      true: true,
      false: true,
      nil: true,
      mult: true,
      exp: true,
      open_paren: true,
      open_curly: true,
      open_square: true
    }

    def disjoint?
      DISJOINT[top.name]
    end

    def parse_disjoint( rule=nil )
      indent = top.indent
      exprs  = []

      while top.indent == indent
        exprs << parse_expression( nil, rule )

        break  unless disjoint?
      end

      case exprs.length
        when 0  then false
        when 1  then exprs.first
        else         Expr.disjoint( *exprs )
      end
    end

    def parse_expression( expr=nil, rule=nil )
      value = expr || parse_rule( :prefix ) || parse_rule( :value ) ||
        parse_interpolated_string || parse_uninterpolated_string ||
        parse_single_prefix_string

      unless value
        if top === :end
          raise UnexpectedEndError.new
        else
          raise "Unexpected token: #{top.name}:#{top}"
        end
      end

      while infix = parse_rule( :postfix, value ) || parse_infix( value, rule )
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
        elsif e = parse_disjoint
          Expr.block( e )
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
        elsif ! (r.right_optional? && top === r.right_optional)
          consume( :newline )
          right = parse_disjoint( r )
        end

        unless right || r.right_optional?
          raise "Infix operator without right side!"
        end

        r.exec( self, t, left, right )
      end
    end

    def parse_statement( statement, token )
      if condition = parse_disjoint
        if top === :newline && parse_line_separator
          if block = parse_block( token.indent )
            if block_given?
              yield( token, condition, block )
            else
              Expr.send( token.name, condition, block )
            end
          else
            raise "Error: #{statement} statement without block"
          end
        else
          raise NewlineExpectedError.new
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
            ary << Expr.string( s )  unless s.empty?
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
            ary << Expr.string( s )  unless s.empty?

            scanner.position = ss.position
            scanner.next_token

            ary << parse_disjoint

            unless top === :close_curly
              raise "Expected end of string interpolation!"
            end
            
            ss.position = scanner.position
            s = ''
          when t === :character
            s << t.value

          else raise "Unexpected token in interpolated string: #{t.name}:#{t}"
        end
      end

      scanner.position = ss.position
      scanner.next_token

      consume( :double_quote )

      Expr.interp_string( *ary )
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

      Expr.string( s )
    end

    def parse_single_prefix_string
      return false  unless top === :colon

      p = scanner.position
      s = ''
      ss = SinglePrefixScanner.new( source, p )

      while t = ss.next_token
        case
          when t === :colon && s.empty?
            scanner.position = ss.position
            return parse_double_prefix_string
          when t === :whitespace || t === :end || t === :close
            break
          when t === :character || t === :colon
            scanner.position = ss.position
            s << t.value

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end
      end

      unless s.empty?
        scanner.next_token

        Expr.string( s )
      end
    end

    def parse_double_prefix_string
      p = scanner.position
      s, ws, ary = '', '', []
      ss = DoublePrefixScanner.new( source, p )

      t = ss.skip( :whitespace )

      while t
        case
          when t === :colon && s.empty? && ary.empty?
            scanner.position = ss.position
            return parse_triple_prefix_string
          when t === :end || t === :close
            break
          when t === :open_interp
            s   << ws
            ary << Expr.string( s )  unless s.empty?

            scanner.position = ss.position
            scanner.next_token

            ary << parse_disjoint

            unless top === :close_curly
              raise "Expected end of string interpolation!"
            end
            
            ss.position = scanner.position
            s, ws = '', ''
          when t === :whitespace
            scanner.position = ss.position
            ws << t.value
          when t === :character
            scanner.position = ss.position
            s << ws
            s << t.value
            ws = ''

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end

        t = ss.next_token
      end

      unless s.empty?
        scanner.next_token

        ary << Expr.string( s )
      end

      Expr.interp_string( *ary )
    end

    def parse_triple_prefix_string
      p = scanner.position
      s, ws, ary = '', '', []
      mi, i = top.indent, nil
      ss = TriplePrefixScanner.new( source, p )

      while t = ss.next_token
        case
          when t === :whitespace
            # nop
          when t === :newline
            break
          else raise NewlineExpectedError.new
        end
      end

      start = true

      while t = ss.next_token
        case
          when t === :end
            break
          when t === :newline
            s << t.value

            start = true
            ws = ''
          when t === :open_interp
            ary << Expr.string( s )  unless s.empty?

            scanner.position = ss.position
            scanner.next_token

            ary << parse_disjoint

            unless top === :close_curly
              raise "Expected end of string interpolation!"
            end
            
            ss.position = scanner.position
            s, ws = '', ''
          when t === :whitespace && start
            scanner.position = ss.position
            ws << t.value
          when t === :character || t === :whitespace
            if start
              i = ws.length  unless i

              break  unless ws.length > mi

              s << ' ' * (ws.length - i)

              start = false
            end

            scanner.position = ss.position
            s << t.value

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end
      end

      unless s.empty?
        scanner.next_token

        ary << Expr.string( s )
      end

      if ary.empty?
        raise "Expected block for ::: prefix string"
      end

      Expr.interp_string( *ary )
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
        Expr.params( *seq.flatten.list )
      else
        Expr.params( seq )
      end
    end

    def seq_to_args( seq )
      if seq.seq?
        s = seq.flatten
      else
        s = Expr.seq( seq )
      end

      if bad = s.list.find { |v| ! v.id? }
        # TODO:  Actually verify new arg list format
        #raise "Arg list may only contain ids: #{s}:#{bad}"
      end

      Expr.args( *s.list )
    end

    def params_to_args( params )
      if bad = params.find { |v| ! v.id? }
        raise "Arg list may only contain ids: #{s}:#{bad}"
      end

      Expr.args( *params.list )
    end


    RULES = RuleSet.new do
      value( :number )
      value( :id )
      value( :true )
      value( :false )
      value( :nil )

      value( :mult )      { |t| Expr.glob( t ) }
      value( :exp )       { |t| Expr.double_glob( t ) }
      value( :question )  { |t| Expr.optional( t ) }
      value( :band )      { |t| Expr.amp( t ) }

      infix( :if,     2 ) { |t,left,right| Expr.cif( left, right ) }
      infix( :unless, 2 ) { |t,left,right| Expr.cun( left, right ) }

      infix( :while,  2 ) { |t,left,right| Expr.cwhile( left, right ) }
      infix( :until,  2 ) { |t,left,right| Expr.cuntil( left, right ) }

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
        right = Expr.block( right ) unless right.block?

        Expr.fn( left.to_params, right )
      end

      infix( :comma, 5 ) { |t,left,right| Expr.seq( left, right ) }

      infix( :colon, 6 ) do |t,left,right|
        if left.atom?
          Expr.pair( Expr.id( left ), right )
        else
          raise "Expected left side of pair to be id, got #{left}"
        end
      end

      infix( :question, 7 ) do |t,left,right|
        if consume( :colon )
          if e = parse_disjoint( Rule.new( :eif, 4 ) )
            Expr.if( left, right, e )
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

      infix( :open_paren, '*', :right, 
        right_optional: :close_paren ) do |t,left,right|

        unless left.id? || left.fn? || left.call?
          raise "Function calls require id or fn or call, not #{left}"
        end

        raise "Expected ) got #{t}"  unless consume( :close_paren )

        if right
          Expr.call( left, right.to_args )
        else
          Expr.call( left, Expr.args )
        end
      end

      prefix( :open_paren ) do |t|
        if consume( :close_paren )
          expr = nil
        else
          expr = parse_disjoint

          # I don't think it's possible to reach this line... (?)
          raise "Expected ) got #{t}"  unless consume( :close_paren )
        end

        expr || Expr.seq
      end

      prefix( :open_curly ) do |t|
        expr = parse_disjoint

        raise "Expected } got #{t}"  unless consume( :close_curly )

        Expr.map( Expr.seq( expr ).flatten.list )
      end

      infix( :open_square, '*', :right, 
        right_optional: :close_square ) do |t,left,right|

        raise "Expected ] got #{t}"  unless consume( :close_square )

        if right
          SendExpr.new( left, Expr.id( '[]' ), right.to_args )
        else
          SendExpr.new( left, Expr.id( '[]' ), Expr.args )
        end
      end

      prefix( :open_square ) do |t|
        expr = parse_disjoint

        raise "Expected ] got #{t}"  unless consume( :close_square )

        Expr.list( (expr || Expr.seq).flatten.list )
      end

      prefix( :fn ) do |t|
        if top === :newline && parse_line_separator
          Expr.fn( Expr.params, parse_block( t.indent ) )
        elsif expr = parse_disjoint
          Expr.fn( Expr.params, Expr.block( expr ) )
        else
          Expr.fn( Expr.params, Expr.block )
        end
      end

      prefix( :not,  18 )
      prefix( :bnot, 18 )

      postfix( :not, 19, :right ) do |t,left|
        SendExpr.new( left, Expr.id( '!' ), Expr.args )
      end

      infix( :dot, 19 ) do |t,left,right|
        unless right.id? || right.call?
          raise "Expected #{left}.id got #{right}"
        end

        if right.call?
          SendExpr.new( left, *right.list )
        else
          SendExpr.new( left, right, Expr.args )
        end
      end

      prefix( :sub,   20, op: :neg )
      prefix( :band,  20, op: :nocall )

      prefix( :if ) do |t|
        parse_statement( :if, t ) do |t, condition, block|
          if e = parse_else( t.indent )
            Expr.if( condition, block, e )
          else
            Expr.if( condition, block )
          end
        end
      end

      prefix( :unless ) do |t|
        parse_statement( :unless, t ) do |t,condition,block|
          Expr.unless( condition, block )
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

