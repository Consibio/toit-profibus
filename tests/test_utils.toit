import expect show *

/**
Used to compare the test
*/
compare_test --expected --result --case/string:
  expect (expected == result) 
    --message="Test Failed! $case was $result, expected $case to be: $expected"
