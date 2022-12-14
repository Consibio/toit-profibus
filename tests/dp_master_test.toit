import ..src.dp_slave
import ..src.dp_master
import rs485
import ..src.util
import gpio
import ..src.dp

class DummyMaster extends DpMaster:
  constructor --rs485_bus --address:
    super --rs485_bus=rs485_bus --address=address
  
  execute --dp_telegram/DpTelegram -> ByteArray:
    //TODO: REMOVE PRINT 
    print dp_telegram.dp_to_fdl_telegram.to_byte_array
    return dp_telegram.dp_to_fdl_telegram.to_byte_array

test_handle_fc:
  rs485_bus := rs485.Rs485 --baud_rate=9600 --rx=(gpio.Pin 22) --tx=(gpio.Pin 23)

  dp_master := DummyMaster --address=2 --rs485_bus=rs485_bus

  dp_slave := DpSlave --address=20 --station_status=4 --wd_fact_1=1 --wd_fact_2=5 --min_TSDR=0 --ident_number=0x06D1 --group_indent=0

  first_diagnose_telegram := dp_master.diagnose_slave --slave=dp_slave
  second_diagnose_telegram := dp_master.diagnose_slave --slave=dp_slave
  third_diagnose_telegram := dp_master.diagnose_slave --slave=dp_slave

  compare_test --expected=0x6d --result=first_diagnose_telegram.fc --case="fc in first request"
  compare_test --expected=0x5d --result=second_diagnose_telegram.fc --case="fc alternates to 5d request"
  compare_test --expected=0x7d --result=third_diagnose_telegram.fc --case="fc alternates to 7d request"


main:
  test_handle_fc

