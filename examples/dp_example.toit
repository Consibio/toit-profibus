import ..src.dp
import ..src.dp_master
import ..src.dp_slave
import rs485
import gpio
import uart
import binary

RX ::= 22
TX ::= 23
RTS ::= 14
BAUD_RATE ::= 9600 //Max recommended baudrate: 1500000

main:

  pin_rx := gpio.Pin  RX
  pin_tx := gpio.Pin  TX
  pin_rts := gpio.Pin RTS

  rs485_bus := rs485.Rs485
    --rx=pin_rx
    --tx=pin_tx
    --rts=pin_rts
    --baud_rate=BAUD_RATE
    --parity=uart.Port.PARITY_EVEN

  master := DpMaster 
    --address=2 
    --rs485_bus=rs485_bus

  slave_one := DpSlave 
    --address=20 
    --station_status=0x80 
    --wd_fact_1=1 
    --wd_fact_2=2 
    --min_TSDR=0 
    --ident_number=0x06D1 
    --group_indent=0
  
  master.setup --slave=slave_one

  1000.repeat:
    data := master.data_exchange --slave=slave_one --du=#[0x01]
    time := Time.now.local
    print "Time: $(%02d time.h):$(%02d time.m) Data from the slave: $data"
    print "Main measured value: $(%.2f binary.BIG_ENDIAN.float32 data 0x08)"
    print "Secondary measured value: $(%.1f binary.BIG_ENDIAN.float32 data 0x0C)"
    sleep --ms=1000
    //check if data byte is 0x11, or else the sensors are faulty
    //check if the data is null, it happens if the slave goes offline. 
