
test( 'add', -> 
  assert_equal( 5, 2 + 3 )
  assert_equal( 12, 7 + 5 )
  assert_equal( 12, 7 + 5 )
  assert_equal( 12, 7.0 + 5.0 )
  assert_equal( 12, 7.2 + 4.8 )
  assert_equal( 12, -7 + 19 )
)

test( 'sub', -> assert_equal( 1, 3 - 2 ) )

