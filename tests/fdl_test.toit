import ..src.dp
import ..src.util
import ..src.fdl

test_to_byte_array:
  dp_diagnose_request := DpTelegramDiagnoseRequest --da=20 --sa=2

  dp_diagnose_request_data := dp_diagnose_request.dp_to_fdl_telegram.to_byte_array

  compare_test --expected=0x68 --result=dp_diagnose_request_data[0] --case="Diagnosis telegram SD2 byte"
  compare_test --expected=0x05 --result=dp_diagnose_request_data[1] --case="Diagnosis telegram le byte"
  compare_test --expected=0x05 --result=dp_diagnose_request_data[2] --case="Diagnosis telegram le repeat byte"
  compare_test --expected=0x68 --result=dp_diagnose_request_data[3] --case="Diagnosis telegram SD2 byte"
  compare_test --expected=0x94 --result=dp_diagnose_request_data[4] --case="Diagnosis telegram da byte"
  compare_test --expected=0x82 --result=dp_diagnose_request_data[5] --case="Diagnosis telegram sa byte"
  compare_test --expected=0x4d --result=dp_diagnose_request_data[6] --case="Diagnosis telegram fc byte"
  compare_test --expected=0x3C --result=dp_diagnose_request_data[7] --case="Diagnosis telegram dae byte"
  compare_test --expected=0x3E --result=dp_diagnose_request_data[8] --case="Diagnosis telegram sae byte"
  compare_test --expected=0xDD --result=dp_diagnose_request_data[9] --case="Diagnosis telegram fcs byte"
  compare_test --expected=0x16 --result=dp_diagnose_request_data[10] --case="Diagnosis telegram ed byte"

test_calc_fcs:
  dp_diagnose_request := DpTelegramDiagnoseRequest --da=20 --sa=2
  fdl_diagnose_reqest := dp_diagnose_request.dp_to_fdl_telegram

  // Simple data
  data_one := #[0x01, 0x02, 0x03]
  // Should overflow
  data_two := #[0xDF, 0x9F]
  // Empty data
  data_three := #[]

  compare_test --expected=0x06 --result=(FdlTelegram.calc_fcs data_one) --case="Calc fcs with data one byte array"
  compare_test --expected=0x7E --result=(FdlTelegram.calc_fcs data_two) --case="Calc fcs with data two byte array"
  compare_test --expected=0x00 --result=(FdlTelegram.calc_fcs data_three) --case="Calc fcs with data three byte array"

test_set_prm_fdl_telegram:
  dp_set_prm_request := DpTelegramSetPrmRequest --da=20 --sa=2 --ident_number=0x06D1 --group_indent=0 --user_prm=#[0x44]
  fdl_set_prm_request := dp_set_prm_request.dp_to_fdl_telegram.to_byte_array

  compare_test --expected=19 --result=fdl_set_prm_request.size --case="prm telegram has correct data unit length"
  compare_test --expected=#[0x68, 0x0d, 0x0d, 0x68, 0x94, 0x82, 0x4d, 0x3d, 0x3e, 128, 1, 1, 0, 06, 209, 0, 68, 0x7b, 0x16] --result=fdl_set_prm_request --case="data unit telegram values are correct"

test_get_cfg_fdl_telegram:
  dp_get_cfg_request := DpTelegramGetCfgRequest --da=20 --sa=2
  expected_byte_array := #[0x68, 0x05, 0x05, 0x68, 0x94, 0x82, 0x4D, 0x3B, 0x3E, 0xDC, 0x16]
  compare_test --expected=expected_byte_array --result=dp_get_cfg_request.dp_to_fdl_telegram.to_byte_array --case="Check get cfg telegram is built correct"

test_chk_cfg_fdl_telegram:
  response_du := #[0x01, 0x02]
  dp_chk_cfg_request := DpTelegramChkCfg --da=20 --sa=2 --fc=0x6d --du=response_du
  expected_byte_array := #[0x68, 0x07, 0x07, 0x68, 0x94, 0x82, 0x6d, 0x3e, 0x3e, 0x01, 0x02, 0x02, 0x16] 
  compare_test --expected=expected_byte_array --result=dp_chk_cfg_request.dp_to_fdl_telegram.to_byte_array --case="Check chk cfg telegram is built correct"


test_byte_array_to_no_data_fdl_telegram:
  input_byteArray := #[0x10, 0x02, 0x14, 0x6d, 0x83, 0x16]
  byte_array_to_fdl_telegram := FdlTelegram.byte_array_to_fdl input_byteArray
  expected_fdlTelegram := FdlTelegramNoData --da=2 --sa=20 --fc=0x6d

  compare_test --expected=expected_fdlTelegram.sd --result=byte_array_to_fdl_telegram.sd --case="check sd (no data)"
  compare_test --expected=expected_fdlTelegram.da --result=byte_array_to_fdl_telegram.da --case="check da (no data)"
  compare_test --expected=expected_fdlTelegram.sa --result=byte_array_to_fdl_telegram.sa --case="check sa (no data)"
  compare_test --expected=expected_fdlTelegram.fc --result=byte_array_to_fdl_telegram.fc --case="check fc (no data"
  compare_test --expected=expected_fdlTelegram.ed --result=byte_array_to_fdl_telegram.ed --case="check ed (no data)"

test_byte_array_to_variable_fdl_telegram:
  diagnose_response := #[0x68, 0x0b, 0x0b, 0x68, 0x82, 0x94, 0x08, 0x3e, 0x3c, 0x02, 0x05, 0x80, 0xff, 0x06, 0xd1, 0xf5, 0x16]
  byte_array_to_fdl_telegram := FdlTelegram.byte_array_to_fdl diagnose_response
  expected_fdlTelegram := FdlTelegramVariableData --da=2 --sa=20 --fc=0x08 --dae=0x3e --sae=0x3c --du=#[0x02, 0x05, 0x80, 0xff, 0x06, 0xd1]

  compare_test --expected=expected_fdlTelegram.sd --result=byte_array_to_fdl_telegram.sd --case="check sd (var)"
  compare_test --expected=expected_fdlTelegram.calc_le --result=byte_array_to_fdl_telegram.calc_le --case="check le (var)"
  compare_test --expected=expected_fdlTelegram.da --result=byte_array_to_fdl_telegram.da --case="check da (var)"
  compare_test --expected=expected_fdlTelegram.sa --result=byte_array_to_fdl_telegram.sa --case="check sa (var)"
  compare_test --expected=expected_fdlTelegram.fc --result=byte_array_to_fdl_telegram.fc --case="check fc (var)"
  compare_test --expected=expected_fdlTelegram.dae --result=byte_array_to_fdl_telegram.dae --case="check dae (var)"
  compare_test --expected=expected_fdlTelegram.sae --result=byte_array_to_fdl_telegram.sae --case="check sae (var)"
  compare_test --expected=expected_fdlTelegram.du --result=byte_array_to_fdl_telegram.du --case="check du (var)"
  compare_test --expected=(FdlTelegram.calc_fcs expected_fdlTelegram.to_byte_array[4..])  --result=(FdlTelegram.calc_fcs byte_array_to_fdl_telegram.to_byte_array[4..]) --case="check fcs (var)"
  compare_test --expected=expected_fdlTelegram.ed --result=byte_array_to_fdl_telegram.ed --case="check ed (var)"

test_byte_array_to_variable_fdl_telegram_data_exchange_case:
  data_exchange_response := #[0x68, 0x04, 0x04, 0x68, 0x02, 0x14, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x16]
  byte_array_to_fdl_telegram := FdlTelegram.byte_array_to_fdl data_exchange_response

  compare_test --expected=0x02 --result=byte_array_to_fdl_telegram.da --case="da is de-extended correct (data_exch)"
  compare_test --expected=0x14 --result=byte_array_to_fdl_telegram.sa --case="sa is de-extended correct (data_exch)"
  compare_test --expected=0x68 --result=byte_array_to_fdl_telegram.sd --case="sd is correct (data_exch)"
  compare_test --expected=0x16 --result=byte_array_to_fdl_telegram.ed --case="end delimiter is correct (data_exch)"
  compare_test --expected=7 --result=byte_array_to_fdl_telegram.du.size --case="data unit has correct length (data_exch)"
  compare_test --expected=0x1e --result=byte_array_to_fdl_telegram.to_byte_array[14] --case="fcs is correct (data_exch)"
  
test_byte_array_to_fixed_variable_fdl_telegram:
  fixed_var_response := #[0xA2, 0x02, 0x14, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6b, 0x16]
  byte_array_to_fdl_telegram := FdlTelegram.byte_array_to_fdl fixed_var_response

  compare_test --expected=0x02 --result=byte_array_to_fdl_telegram.da --case="da in fdl (fixed var)"
  compare_test --expected=0x14 --result=byte_array_to_fdl_telegram.sa --case="sa in fdl (fixed var)"
  compare_test --expected=0xa2 --result=byte_array_to_fdl_telegram.sd --case="sd in fdl (fixed var)"
  compare_test --expected=0x16 --result=byte_array_to_fdl_telegram.ed --case="end delimiter in fdl (fixed var)"
  compare_test --expected=8 --result=byte_array_to_fdl_telegram.du.size --case="data unit in fdl is length (fixed var)"
  compare_test --expected=0x6b --result=byte_array_to_fdl_telegram.to_byte_array[12] --case="fcs calculation (fixed var)"  

test_short_acknowledge_telegram:
  short_ack_response := #[0xE5]
  short_ack_Fdltelegram := FdlTelegram.byte_array_to_fdl short_ack_response

  compare_test --expected=true --result=short_ack_Fdltelegram is FdlTelegramShortAcknowledge --case="short ack is recognized"

main:
  test_to_byte_array
  test_calc_fcs
  test_get_cfg_fdl_telegram
  test_set_prm_fdl_telegram
  test_chk_cfg_fdl_telegram
  test_byte_array_to_no_data_fdl_telegram
  test_byte_array_to_variable_fdl_telegram
  test_byte_array_to_variable_fdl_telegram_data_exchange_case
  test_byte_array_to_fixed_variable_fdl_telegram
  test_short_acknowledge_telegram
