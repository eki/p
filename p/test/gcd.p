
gcd := (u, v) ->
  if v != 0
    gcd( v, u % v )
  else
    u < 0 ? -u : u

test( 'gcd(12,30)', -> assert_equal( 6, gcd( 12, 30 ) ) )
test( 'gcd(30,12)', -> assert_equal( 6, gcd( 30, 12 ) ) )

test( 'gcd(6, 3)',  -> assert_equal( 3, gcd( 6, 3 ) ) )

test( 'gcd(1, 1)',  -> assert_equal( 1, gcd( 1, 1 ) ) )
test( 'gcd(1, 2)',  -> assert_equal( 1, gcd( 1, 2 ) ) )
test( 'gcd(2, 3)',  -> assert_equal( 1, gcd( 2, 3 ) ) )
test( 'gcd(2, 4)',  -> assert_equal( 2, gcd( 2, 4 ) ) )

test( 'gcd(23424, 24281856)', -> assert_equal( 384, gcd( 23424, 24281856 ) ) )

