# This is a comment at the very start of this file.
#It actually runs multiple
#      lines
  # And has weird
    # Indentation
##### Strange, right?

test( '34 is 34', -> assert_equal( 34, 34 ) )  # Trailing comment
test( '34 is 34', -> assert_equal( 34, 34 ) )#Trailing comment (again!)

test( 'comments mixed with indentation blocks', ->
# Hi!

  if 2 + 2 == 4
    assert_equal( 4, 2 + 2 )
    # again!
    assert_equal( 4, 2 + 2 )

    # foo!
  else # nothing happens here
  # or here
    # or here


    puts( "ERROR!" )
    # or here
  assert_equal( true, true )  # not in the else!
    

)

# File ends with a comment for no reason!  Yay!
