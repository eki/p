
new_fib_generator := ->
  n, m = nil, nil
  ->
    return n = 0  unless n
    return m = 1  unless m

    n, m = m, n + m
    m

fib := new_fib_generator
gib := new_fib_generator

test( 'fib 1st call', -> assert_equal( 0, fib ) )
test( 'fib 2nd call', -> assert_equal( 1, fib ) )
test( 'fib 3rd call', -> assert_equal( 1, fib ) )
test( 'fib 4th call', -> assert_equal( 2, fib ) )
test( 'fib 5th call', -> assert_equal( 3, fib ) )

test( 'gib 1st call', -> assert_equal( 0, gib ) )

test( 'fib 6th call', -> assert_equal( 5, fib ) )

test( 'gib 2nd call', -> assert_equal( 1, gib ) )

test( 'fib 7th call', -> assert_equal( 8, fib ) )

test( 'gib 3rd call', -> assert_equal( 1, gib ) )

test( 'fib 8th call', -> assert_equal( 13, fib ) )

test( 'gib 4th call', -> assert_equal( 2, gib ) )

