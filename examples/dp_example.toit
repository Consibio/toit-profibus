import ..src.dp
import ..src.dp_master
import ..src.dp_slave
import rs485
import gpio
import uart
import binary

/**
Define the pin numbers to use for RX, TX, and RTS. 
*/
RX ::= 22
TX ::= 23
RTS ::= 14

/**
Set the baud rate to be used. 
During testing we found the max recommended baud rate was 1.5 mbps, 
but try to test what works for you. 
*/
BAUD_RATE ::= 9600

main:
  /**
  Give the defined pin numbers to the gpio library
  */
  pin_rx := gpio.Pin  RX
  pin_tx := gpio.Pin  TX
  pin_rts := gpio.Pin RTS

  /**
  Create a rs485 bus using the defined gpio pins and the rs485 library
  Important: The parity bit needs to be parity even. 
  */
  rs485_bus := rs485.Rs485
    --rx=pin_rx
    --tx=pin_tx
    --rts=pin_rts
    --baud_rate=BAUD_RATE
    --parity=uart.Port.PARITY_EVEN

  /**
  Create a master object and give an address and the created rs485 bus. 
  */
  master := DpMaster 
    --address=2 
    --rs485_bus=rs485_bus

  /**
  Create a slave object for each slave you want to contact. In this example we only have one slave, 
  which is the MIQ/MCS - PR (https://www.xylemanalytics.com/en/general-product/id-168/controller-miqmc3---wtw). 
  Give the slave's address, station_status, wd_fact_1, wd_fact_2, min_TSDR, indent_number, and group_number. 
  Much of the values are default values. For the station_status, the hex value 0x80 indicates to the slave that 
  we have locked the slave for other master, freeze mode and sync mode is not active, and the watchdog is off. 
  If the watchdog is off, the wd_fact_1 and wd_fact_2 does not matter, and the min_TSDR is defualt to 0. 
  The ident_number 0x06D1 is specific to the slave we used for testing, and will be different for other slaves.
  The group control is not used, hence the group_indent is 0. 
  */
  slave_one := DpSlave 
    --address=20 
    --station_status=0x80 
    --wd_fact_1=1 
    --wd_fact_2=2 
    --min_TSDR=0 
    --ident_number=0x06D1 
    --group_indent=0
  
  /**
  To achieve the data exchange state, we need to setup the slave by using the master object and its setup method. 
  Give the slave you want to set up as the input. 
  */
  master.setup --slave=slave_one

  /**
  In this example we want to data exchange for a total of a 1000 times and prints the value. 
  To get data from the slave, simply use the master object and its data_exchange method to the specfied slave. 
  The du is in this instance 0x01, since we want to tell the slave we are using that we want to read data from sensor 1. 
  This value will likely be different for each slave manufactorer, and you need to be aware of how the data can be read from 
  your specific slave. 
  */
  1000.repeat:
    data := master.data_exchange --slave=slave_one --du=#[0x01]
    time := Time.now.local
    print "Time: $(%02d time.h):$(%02d time.m) Data from the slave: $data"
    print "Main measured value: $(%.2f binary.BIG_ENDIAN.float32 data 0x08)"
    print "Secondary measured value: $(%.1f binary.BIG_ENDIAN.float32 data 0x0C)"
    sleep --ms=1000
