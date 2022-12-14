import expect show *

compare_test --expected --result --case/string:
  expect (expected == result) 
    --message="Test Failed! $case was $result, expected $case to be: $expected"
