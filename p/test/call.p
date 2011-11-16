
foo = new( -> x = -> 3 )

bar = new( -> x = 3 )

test( "34",      -> assert_equal( 34, 34 ) )
test( "34()",    -> assert_equal( 34, 34() ) )
test( "foo.x",   -> assert_equal( 3, foo.x ) )
test( "foo.x()", -> assert_equal( 3, foo.x() ) )
test( "bar.x",   -> assert_equal( 3, bar.x ) )
test( "bar.x()", -> assert_equal( 3, bar.x() ) )

foo = 34.clone

test( "foo (34.clone)", -> 
  assert_equal( 34, foo.to_integer )        # shouldn't all the number == make
  assert_equal( 34, foo().to_integer ) )    # implicit to_XXX calls?

foo = 34.clone( -> call := 35 )

test( "clone w/ call := 35", -> 
  assert_equal( 35, foo )
  assert_equal( 35, foo() ) )

foo = 34.clone( -> x := -> to_integer + 7 )

test( "clone w/ explicit call to x := -> to_integer + 7", -> 
  assert_equal( 41, foo.x )
  assert_equal( 41, foo.x() ) )

foo = 34.clone( -> x := -> self + 7 )

test( "clone w/ explicit call to x := -> self + 7", -> 
  assert_equal( 41, foo.x )
  assert_equal( 41, foo.x() ) )

foo = 34.clone( -> call := -> to_integer + 7 )

test( "clone w/ call := -> to_integer + 7", -> 
  assert_equal( 41, foo )
  assert_equal( 41, foo() ) )

foo = 34.clone( -> call := -> &self + 7 )    # &self is necessary to avoid
                                             # infinite recursion
test( "clone w/ call := -> &self + 7", -> 
  assert_equal( 41, foo )
  assert_equal( 41, foo() ) )

test( "call in ?:", ->
  assert_equal( 41, foo == 41 ? foo() : 22 ) )

