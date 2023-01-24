/*
Represent a DP slave and contains the information needed for setting up a connection with a master. 
*/
class DpSlave:

  /**
  Slave address
  */
  address/int

  /**
  Station status of the slave. 
  See specficifation of which values it can be to turn specific features on or off, 
  such as the watchdog or if the slave is locked or unlocked. 
  */
  station_status/int

  /**
  Watchdog fact 1.
  Used for calculating the watchdog timer. 
  The watchdog can be turned off or on in the station status octet.
  */
  wd_fact_1/int

  /**
  Watchdog fact 2.
  Used for calculating the watchdog timer. 
  The watchdog can be turned off or on in the station status octet.
  */
  wd_fact_2/int

  /**
  Minimum time a slave will wait before it is allowed to send a response to a master.
  If 0x00 is specified, default or previous value will be used. 
  */
  min_TSDR/int

  /**
  The slave's ident number. 
  Transmitted for security purposes. 
  Can be found in the slave's GSD file. 
  */
  ident_number/int

  /**
  Group ident number used for global control. 
  */
  group_indent/int

  /**
  User-defined octets in a byte array for specific slave devices. 
  See the slave's GSD for user specfic parameterization octets. 
  */
  user_prm/ByteArray

  constructor --.address --.station_status --.wd_fact_1 --.wd_fact_2 --.min_TSDR --.ident_number --.group_indent --.user_prm=#[]:

