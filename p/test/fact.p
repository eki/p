
fact := (n) ->
  if n <= 1
    1
  else
    fact( n - 1 ) * n

test( 'fact(0)', -> assert_equal(   1, fact( 0 ) ) )
test( 'fact(1)', -> assert_equal(   1, fact( 1 ) ) )
test( 'fact(2)', -> assert_equal(   2, fact( 2 ) ) )
test( 'fact(3)', -> assert_equal(   6, fact( 3 ) ) )
test( 'fact(4)', -> assert_equal(  24, fact( 4 ) ) )
test( 'fact(5)', -> assert_equal( 120, fact( 5 ) ) )

