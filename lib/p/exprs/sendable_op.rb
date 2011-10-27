
module P

  SENDABLE = { 
    add:    '+',
    sub:    '-',
    mult:   '*',
    div:    '/',
    modulo: '%',

    exp:    '**',

    bnot:   '~',
    band:   '&',
    bor:    '|',
    xor:    '^',

    lshift: '<<',
    rshift: '>>',

    comp:   '<=>',
    eq:     '==',
    gt:     '>',
    lt:     '<',
    gte:    '>=',
    lte:    '<='
  }

  SENDABLE.each do |k,v|
    eval "class #{k.capitalize}Expr < SendableOperatorExpr; op '#{v}'; end"
  end

end

