
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

    def right_with_precedence
      Rule.new( :bogus, opts[:right_with_precedence] || precedence )
    end

    def <=>( r )
      p, rp = precedence, r.precedence

      rp -= 1  if r.associativity == :right

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
      prec  = opts[:precedence]    || 40
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
    attr_reader :source, :scanner, :context

    def initialize( source )
      @source = source
      @scanner = Scanner.new( source )
      @context = :default
      @scanner.next_token( context )
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

      consume( top )  while top == :newline

      if expr = parse_expression
        block = [expr]
      else
        raise "Failed to parse_block at #{top.name}:#{top}"
      end

      while parse_line_separator
        consume( top )  while top === :newline

        if top.indent == indent
          while top.indent == indent
            consume( top )  while top === :newline
            break              if top === :close_paren || top === :end

            block << parse_expression
          end
        elsif top.indent < indent
          return Expr.block( *block )
        elsif top.indent > indent
          block << parse_block
        end
      end

      Expr.block( *block )
    end

    def parse_expression( expr=nil, rule=nil )
      value = expr || parse_rule( :prefix ) || parse_rule( :value ) ||
        parse_string

      unless value
        if top === :end
          raise UnexpectedEndError.new
        else
          raise "Unexpected token: #{top.debug}"
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
        elsif e = parse_expression
          Expr.block( e )
        end
      end
    end

    def parse_infix( left, rule=nil )
      return false  unless left

      r = RULES.for( :infix, top )

      if r && (! rule || r > rule)
        t = consume( top, top.name )

        if r.block? && top === :newline && parse_line_separator
          right = parse_block( t.indent )
        elsif ! (r.right_optional? && top === r.right_optional)
          consume( :newline )
          right = parse_expression( nil, r.right_with_precedence )
        end

        unless right || r.right_optional?
          raise "Infix operator without right side! #{top.debug} :: #{t.debug}"
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

    def parse_string
      parse_interpolated_string  || parse_uninterpolated_string ||
      parse_single_prefix_string || parse_double_prefix_string  ||
      parse_triple_prefix_string
    end

    def parse_interpolated_string
      return false  unless switch_context( :double_quote )

      s, ary = '', []

      while t = switch_context( :default, :open_interp )  || 
                switch_context( :default, :double_quote ) || consume( top )

        case
          when t === :double_quote
            ary << Expr.string( s )  unless s.empty?
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
            s = ''

            ary << parse_expression

            unless switch_context( :double_quote, :close_curly )
              raise "Expected end of string interpolation!"
            end
            
          when t === :character
            s << t.value

          else raise "Unexpected token in interpolated string: #{t.name}:#{t}"
        end
      end

      Expr.interp_string( *ary )
    end

    def parse_uninterpolated_string
      return false  unless switch_context( :single_quote )

      s = ''

      while t = switch_context( :default, :single_quote ) || consume( top )
        case
          when t === :single_quote
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

      Expr.string( s )
    end

    def parse_single_prefix_string
      return false  unless switch_context( :single_colon, :colon )

      s = ''

      while t = switch_context( :default, :whitespace )            ||
                switch_context( :default, :end )                   ||
                switch_context( :default, :close, consume: false ) ||
                consume( top )

        case
          when t === :close
            if s.empty?
              s << consume( top ).value
            else
              scanner.rename_last_token( context )
              break
            end
          when t === :whitespace || t === :end
            break
          when t === :character
            s << t.value

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end
      end

      unless s.empty?
        Expr.string( s )
      end
    end

    def parse_double_prefix_string
      return false  unless switch_context( :double_colon )

      s, ws, ary = '', '', []

      consume( :whitespace )  while top === :whitespace

      while t = switch_context( :default, :open_interp )           ||
                switch_context( :default, :end )                   ||
                switch_context( :default, :close, consume: false ) ||
                consume( top )

        case
          when t === :close
            scanner.rename_last_token( context )
            break
          when t === :end
            break
          when t === :open_interp
            s   << ws
            ary << Expr.string( s )  unless s.empty?
            s, ws = '', ''

            ary << parse_expression

            unless switch_context( :double_colon, :close_curly )
              raise "Expected end of string interpolation!"
            end

          when t === :whitespace
            ws << t.value
          when t === :character
            s << ws
            s << t.value
            ws = ''

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end

      end

      unless s.empty?
        ary << Expr.string( s )
      end

      Expr.interp_string( *ary )
    end

    def parse_triple_prefix_string
      return false  unless (mi = top.indent) && switch_context( :triple_colon )

      s, ws, ary = '', '', []

      unless (t = consume( :newline )) && (i = t.indent) && i > mi
        raise NewlineExpectedError.new
      end

      while t = switch_context( :default, :open_interp )  ||
                switch_context( :default, :end )          ||
                (top === :newline ? top : consume( top ))

        case
          when t === :end
            break
          when t === :newline
            if t.indent < i
              @context = :default
              break
            end

            consume( top )

            s << "\n" << ' ' * (t.indent - i)

          when t === :open_interp
            ary << Expr.string( s )  unless s.empty?
            s, ws = '', ''

            ary << parse_expression

            unless switch_context( :triple_colon, :close_curly )
              raise "Expected end of string interpolation!"
            end

          when t === :character || t === :whitespace
            s << t.value

          else raise "Unexpected token in symbol: #{t.name}:#{t}"
        end
      end

      unless s.empty?
        ary << Expr.string( s )
      end

      if ary.empty?
        raise "Expected block for ::: prefix string"
      end

      Expr.interp_string( *ary )
    end

    def switch_context( context, token=context, opts={ consume: true } )
      if top === token
        @context = context

        scanner.rename_last_token( context )  if opts[:rename]

        opts[:consume] ? consume( token ) : top
      end
    end

    def consume( token, context=context )
      if top === token
        t = top
        scanner.next_token( context )
        t
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

      infix( :if,     20 ) { |t,left,right| Expr.cif( left, right ) }
      infix( :unless, 20 ) { |t,left,right| Expr.cun( left, right ) }

      infix( :while,  20 ) { |t,left,right| Expr.cwhile( left, right ) }
      infix( :until,  20 ) { |t,left,right| Expr.cuntil( left, right ) }

      prefix( :return, 30 ) do |t|
        if e = parse_expression( nil, Rule.new( :cif, 30 ) )
          Expr.return( e )
        else
          raise "return requires expression."
        end
      end

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

      infix( :fn, 41, :right, block: true ) do |t,left,right|
        right = Expr.block( right ) unless right.block?

        e = Expr.fn( left.to_params, right )
        if left.position
          e.source = source[(left.position+1)..(top.position)]
          e.parameters_source = source[(left.position+1)..(t.position)]
        end
        e
      end

      infix( :comma, 50 ) { |t,left,right| Expr.seq( left, right ) }

      infix( :colon, 60 ) do |t,left,right|
        if left.atom?
          Expr.pair( Expr.id( left ), right )
        else
          raise "Expected left side of pair to be id, got #{left}"
        end
      end

      infix( :question, 70, right_with_precedence: 0 ) do |t,left,right|
        if consume( :colon )
          if e = parse_expression( nil, Rule.new( :eif, 0 ) )
            Expr.if( left, right, e )
          else
            raise "Couldn't find else conditional to complete ?:"
          end
        else
          raise "Expected : to complete ?:"
        end
      end

      infix( :bor,     80 )
      infix( :xor,     90 )
      infix( :band,   100 )

      infix( :and,    110 )
      infix( :or,     110 )

      infix( :eq,     120 )
      infix( :neq,    120 )
      infix( :gt,     120 )
      infix( :lt,     120 )
      infix( :gte,    120 )
      infix( :lte,    120 )

      infix( :comp,   130 )

      infix( :lshift, 140 )
      infix( :rshift, 140 )
      
      infix( :add,    150 )
      infix( :sub,    150 )

      infix( :mult,   160 )
      infix( :div,    160 )
      infix( :modulo, 160 )

      infix( :exp,    170 ) 

      infix( :open_paren, 190, :right, right_with_precedence: 0, # was 49
        right_optional: :close_paren ) do |t,left,right|

        raise "Expected ) got #{top.debug}"  unless consume( :close_paren )

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
          expr = parse_expression

          # I don't think it's possible to reach this line... (?)
          raise "Expected ) got #{t}"  unless consume( :close_paren )
        end

        e = expr || Expr.seq
        e.position = t.position
        e
      end

      prefix( :open_curly ) do |t|
        expr = parse_expression

        raise "Expected } got #{t}"  unless consume( :close_curly )

        Expr.map( Expr.seq( expr ).flatten.list )
      end

      infix( :open_square, 190, :right, right_with_precedence: 0, # was 200
        right_optional: :close_square ) do |t,left,right|

        raise "Expected ] got #{t}"  unless consume( :close_square )

        if right
          SendExpr.new( left, Expr.id( '[]' ), right.to_args )
        else
          SendExpr.new( left, Expr.id( '[]' ), Expr.args )
        end
      end

      prefix( :open_square ) do |t|
        expr = parse_expression

        raise "Expected ] got #{t}"  unless consume( :close_square )

        Expr.list( (expr || Expr.seq).flatten.list )
      end

      prefix( :fn, 190 ) do |t|
        if top === :newline && parse_line_separator
          e = Expr.fn( Expr.params, parse_block( t.indent ) )
        elsif expr = parse_expression( nil, Rule.new( :cif, 41 ) )
          e = Expr.fn( Expr.params, Expr.block( expr ) )
        else
          e = Expr.fn( Expr.params, Expr.block )
        end
        e.source = source[(t.position+1)..(top.position)]
        e
      end

      prefix( :not,  180 )
      prefix( :bnot, 180 )

      postfix( :not, 210, :right ) do |t,left|
        SendExpr.new( left, Expr.id( '!' ), Expr.args )
      end

      infix( :dot, 210 ) do |t,left,right|
        unless right.id? || right.call?
          raise "Expected #{left}.id got #{right}"
        end

        if right.call?
          SendExpr.new( left, *right.list )
        else
          SendExpr.new( left, right, Expr.args )
        end
      end

      prefix( :sub,   200, op: :neg )
      prefix( :band,  200, op: :nocall )

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

