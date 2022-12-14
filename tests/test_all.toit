import ..tests.dp_master_test as dp_master_test
import ..tests.dp_slave_test as dp_slave_test
import ..tests.dp_test as dp_test
import ..tests.fdl_test as fdl_test

main:
  //dp_master_test.main
  dp_slave_test.main
  dp_test.main
  fdl_test.main



