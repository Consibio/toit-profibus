/*
Represent a DP slave and contains the information needed for setting up a connection with a master. 
*/
class DpSlave:

  address/int
  station_status/int
  wd_fact_1/int
  wd_fact_2/int
  min_TSDR/int
  ident_number/int
  group_indent/int
  user_prm/ByteArray

  constructor --.address --.station_status --.wd_fact_1 --.wd_fact_2 --.min_TSDR --.ident_number --.group_indent --.user_prm=#[]:

