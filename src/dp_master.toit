import rs485
import .dp_slave
import .dp
import .fdl 

class DpMaster:

  // Since we cannot manually control the idle line bits, which should be 33 bits of logical 1, 
  // we simulate this by sending a SYN byte array before sending the actual telegram. 
  static SYN/ByteArray ::= #[0xFF, 0xFF, 0xFF, 0xFF]

  //FC Map to handle the fc byte
  fc_map/Map := {:}

  rs485_bus/rs485.Rs485
  address/int
  time_out_ms/int ::= 1000 //Should this be a master parameter --timeout_timer

  constructor --.rs485_bus --.address:
  
  execute --dp_telegram/DpTelegram:
    dp_telegram_response/DpTelegram? := null
    try:
      rs485_bus.do_transmission:
        rs485_bus.write SYN
        rs485_bus.write dp_telegram.dp_to_fdl_telegram.to_byte_array
      response := null
      with_timeout --ms = time_out_ms:
        response = rs485_bus.read
      if response != null:
        fdl_telegram_response := FdlTelegram.byte_array_to_fdl response
        dp_telegram_response = DpTelegram.fdl_to_dp fdl_telegram_response
    finally:
      return dp_telegram_response

  handle_fc slave/DpSlave -> int:
    fc := fc_map.get slave.address
    if fc == null:
      fc = FdlTelegram.FC_FIRST_REQUEST
    else if fc == FdlTelegram.FC_FIRST_REQUEST:
      fc ^= 0x30
    else:
      fc ^= 0x20
    fc_map[slave.address] = fc
    return fc

  diagnose_slave --slave/DpSlave -> DpTelegramDiagnoseResponse?:
    diagnose_request := DpTelegramDiagnoseRequest --da=slave.address --sa=address --fc=(handle_fc slave)
    diagnose_response := ensure_response_from_slave --dp_telegram=diagnose_request
    return diagnose_response

  paramerterize_slave --slave/DpSlave -> DpTelegramShortAcknowledgeResponse:
    parameterize_request := DpTelegramSetPrmRequest 
      --da=slave.address 
      --sa=address 
      --fc=(handle_fc slave) 
      --station_status=slave.station_status
      --wd_fact_1=slave.wd_fact_1
      --wd_fact_2=slave.wd_fact_2
      --min_TSDR=slave.min_TSDR
      --ident_number=slave.ident_number
      --group_indent=slave.group_indent
      --user_prm=slave.user_prm   
    parameterize_response := ensure_response_from_slave --dp_telegram=parameterize_request
    return parameterize_response

  get_config --slave/DpSlave -> ByteArray?:
    get_cfg_request := DpTelegramGetCfgRequest --da=slave.address --sa=address --fc=(handle_fc slave)
    get_cfg_response := ensure_response_from_slave --dp_telegram=get_cfg_request
    return get_cfg_response.du
    
  check_config --slave/DpSlave --config_du -> DpTelegramShortAcknowledgeResponse:
    chk_config_request := DpTelegramChkCfg --da=slave.address --sa=address --fc=(handle_fc slave) --du=config_du
    chk_config_response := ensure_response_from_slave --dp_telegram=chk_config_request
    return chk_config_response

  ensure_response_from_slave --dp_telegram/DpTelegram:
    response/DpTelegram? := null
    while true:
      response = execute --dp_telegram=dp_telegram
      if response != null:
        break
    return response

  setup --slave/DpSlave:
    diagnose_response := diagnose_slave --slave=slave
      
    if diagnose_response.is_ready_for_data_exchange:
      return
    
    if diagnose_response.prm_required:
      paramerterize_slave --slave=slave
    
    diagnose_response = diagnose_slave --slave=slave

    if diagnose_response.prm_required:
      throw "SET PRM FAILED"
    
    config_du := get_config --slave=slave
    check_config --slave=slave --config_du=config_du
    
    sleep --ms=100

    diagnose_response = diagnose_slave --slave=slave

    if diagnose_response.cfg_fault:
      throw "CHECK CONFIG FAILED, DETECTED MISMATCH"

    if not diagnose_response.is_ready_for_data_exchange:
      throw "NOT READY FOR DATA EXCHANGE, SOMETHING WENT WRONG"

  data_exchange --slave/DpSlave --du/ByteArray:
    data_exchange_request := DpTelegramDataExchangeRequest --da=slave.address --sa=address --fc=(handle_fc slave) --du=du
    data_exchange_response := ensure_response_from_slave --dp_telegram=data_exchange_request
    if data_exchange_response is not DpTelegramDataExchangeResponse:
      setup --slave=slave
      return null
    else:
      return data_exchange_response.du
    
