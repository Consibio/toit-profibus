import ..src.dp_slave
import ..src.util

test_dp_slave:
  dp_slave := DpSlave --address=20 --station_status=4 --wd_fact_1=1 --wd_fact_2=5 --min_TSDR=0 --ident_number=0x06D1 --group_indent=0

  compare_test --expected=20 --result=dp_slave.address --case="address"

  compare_test --expected=4 --result=dp_slave.station_status --case="station status"

  compare_test --expected=1 --result=dp_slave.wd_fact_1 --case="wd fact 1"

  compare_test --expected=5 --result=dp_slave.wd_fact_2 --case="wd fact 2"

  compare_test --expected=0 --result=dp_slave.min_TSDR --case="min TSDR"

  compare_test --expected=0x06D1 --result=dp_slave.ident_number --case="ident number"

  compare_test --expected=0 --result=dp_slave.group_indent --case="group ident"

main:
  test_dp_slave


