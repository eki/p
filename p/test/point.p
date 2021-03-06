
origin := new( ->
  x, y := 0, 0
  to_string := -> "(#{x},#{y})" 
  inspect := [:x, :y]
  point?  := true
  '+'  := (point) ->
    clone( -> 
      x := x + point.x
      y := y + point.y ) 
  '==' := (point) -> point.x == x && point.y == y )

Point := new( ->
  proto := origin
  new   := (x, y) -> origin.clone( -> 
    x, y := x, y )
  to_string := -> "Point" )


test( 'origin', ->
  assert_equal( true, origin.point? )
  assert_equal( 0, origin.x )
  assert_equal( 0, origin.y )
  assert_equal( true, origin == origin )
  assert_equal( true, origin == origin.clone )
)

test( 'Point', ->
  p = Point.new( 4, 4 )
  q = Point.new( 8, 1 )

  assert_equal( 12, (p + q).x )
  assert_equal(  5, (p + q).y )
  assert_equal( Point.new( 12, 5 ), p + q )

  assert_equal( 12, (q + p).x )
  assert_equal(  5, (q + p).y )
  assert_equal( Point.new( 12, 5 ), q + p )
)

