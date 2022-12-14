import ..src.dp
import ..src.fdl
import ..src.util

test_get_cfg_telegram:
  dp_get_cfg_request := DpTelegramGetCfgRequest --da=20 --sa=2
  compare_test --expected=0x14 --result=dp_get_cfg_request.da --case="Get cfg 'da'"
  compare_test --expected=0x02 --result=dp_get_cfg_request.sa --case="Get cfg 'sa'"
  compare_test --expected=0x4D --result=dp_get_cfg_request.fc --case="Get cfg 'fc'"
  compare_test --expected=0x3B --result=dp_get_cfg_request.dsap --case="Get cfg 'dsap'"
  compare_test --expected=0x3E --result=dp_get_cfg_request.ssap --case="Get cfg 'ssap'"

test_chk_cfg_telegram:
  response_du := #[0x01, 0x02]
  dp_chk_cfg_request := DpTelegramChkCfg --da=20 --sa=2 --fc=0x6d --du=response_du
  // [SD = 0x68, LE = 0x07, LEr = 0x07, SD = 0x68, DA = 0x94, SA = 0x82, FC = 0x6d, DSAP = 0x3e, SSAP = 0x3e, DU[0] = 0x01, DU[1] = 0x02, FCS = 0xe2, ED = 0x16]
  compare_test --expected=0x14 --result=dp_chk_cfg_request.da --case="Check cfg 'da'"
  compare_test --expected=0x02 --result=dp_chk_cfg_request.sa --case="Get cfg 'sa'"
  compare_test --expected=0x6D --result=dp_chk_cfg_request.fc --case="Get cfg 'fc'"
  compare_test --expected=0x3E --result=dp_chk_cfg_request.dsap --case="Get cfg 'dsap'"
  compare_test --expected=0x3E --result=dp_chk_cfg_request.ssap --case="Get cfg 'ssap'"
  compare_test --expected=0x01 --result=dp_chk_cfg_request.du[0] --case="Get cfg 'du value 1'"
  compare_test --expected=0x02 --result=dp_chk_cfg_request.du[1] --case="Get cfg 'du value 2'"

test_parameterize_request:
  dp_set_prm_request := DpTelegramSetPrmRequest --da=20 --sa=2 --ident_number=0x06D1 --group_indent=0 --user_prm=#[0x44]

  //Test the data unit
  compare_test --expected=8 --result=dp_set_prm_request.du.size --case="prm telegram has correct data unit length"
  compare_test --expected=128 --result=dp_set_prm_request.du[0] --case="station status is locked by default"
  compare_test --expected=1 --result=dp_set_prm_request.du[1] --case="wd_fact_1 default value"
  compare_test --expected=1 --result=dp_set_prm_request.du[2] --case="wd_fact_2 default value"
  compare_test --expected=0 --result=dp_set_prm_request.du[3] --case="min_TSDR default value"
  compare_test --expected=06 --result=dp_set_prm_request.du[4] --case="upper ident_number"
  compare_test --expected=209 --result=dp_set_prm_request.du[5] --case="lower ident_number"
  compare_test --expected=0 --result=dp_set_prm_request.du[6] --case="group indent"
  compare_test --expected=68 --result=dp_set_prm_request.du[7] --case="user_prm"
  compare_test --expected=#[128, 1, 1, 0, 06, 209, 0, 68] --result=dp_set_prm_request.du --case="data unit test"
  
  //Test telegram byte values
  compare_test --expected=77 --result=dp_set_prm_request.fc --case="fc byte"
  compare_test --expected=61 --result=dp_set_prm_request.dsap --case="dsap"
  compare_test --expected=62 --result=dp_set_prm_request.ssap --case="ssap"
  compare_test --expected=20 --result=dp_set_prm_request.da --case="destination"
  compare_test --expected=2 --result=dp_set_prm_request.sa --case="fc byte"

test_fdl_to_dp:
  // Diagnosis //
  raw_diagnose_request := #[0x68, 0x05, 0x05, 0x68, 0x94, 0x82, 0x6d, 0x3c, 0x3e, 0xfd, 0x16]
  fdl_diagnose_request := FdlTelegram.byte_array_to_fdl raw_diagnose_request
  dp_diagnose_request := DpTelegram.fdl_to_dp fdl_diagnose_request
  compare_test --expected=true --result=dp_diagnose_request is DpTelegramDiagnoseRequest --case="Fdl to dp (diagnose request)"

  raw_diagnose_response_one := #[0x68, 0x0b, 0x0b, 0x68, 0x82, 0x94, 0x08, 0x3e, 0x3c, 0x02, 0x05, 0x80, 0xff, 0x06, 0xd1, 0xf5, 0x16]
  fdl_diagnose_response := FdlTelegram.byte_array_to_fdl raw_diagnose_response_one
  dp_diagnose_response := DpTelegram.fdl_to_dp fdl_diagnose_response
  compare_test --expected=true --result=dp_diagnose_response is DpTelegramDiagnoseResponse --case="Fdl to dp (diagnose response)"

  // Data Exchange //
  raw_data_exchange_request := #[0x68, 0x04, 0x04, 0x68, 0x14, 0x02, 0x6D, 0x01, 0x84, 0x16]
  fdl_data_exchange_request := FdlTelegram.byte_array_to_fdl raw_data_exchange_request
  dp_data_exchange_request := DpTelegram.fdl_to_dp fdl_data_exchange_request
  compare_test --expected=true --result=dp_data_exchange_request is DpTelegramDataExchangeRequest --case="Fdl to dp (data exchange request)"

  raw_data_exchange_response := #[0x68, 0x04, 0x04, 0x68, 0x02, 0x14, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1e, 0x16]
  fdl_data_exchange_response := FdlTelegram.byte_array_to_fdl raw_data_exchange_response
  dp_data_exchange_response := DpTelegram.fdl_to_dp fdl_data_exchange_response
  compare_test --expected=true --result=dp_data_exchange_response is DpTelegramDataExchangeResponse --case="Fdl to dp (data exchange response)"

  // Get Config //
  raw_get_cfg_request := #[0x68, 0x03, 0x03, 0x68, 0x94, 0x82, 0x6D, 0x3B, 0x3E, 0xfc, 0x16]
  fdl_get_cfg_request := FdlTelegram.byte_array_to_fdl raw_get_cfg_request
  dp_get_cfg_request := DpTelegram.fdl_to_dp fdl_get_cfg_request
  compare_test --expected=true --result=dp_get_cfg_request is DpTelegramGetCfgRequest --case="Fdl to dp (get cfg request)"

  raw_get_cfg_response := #[0x68, 0x03, 0x03, 0x68, 0x82, 0x94, 0x08, 0x3E, 0x3B, 0x9F, 0xA0, 0xd6, 0x16]
  fdl_get_cfg_response := FdlTelegram.byte_array_to_fdl raw_get_cfg_response
  dp_get_cfg_response := DpTelegram.fdl_to_dp fdl_get_cfg_response
  compare_test --expected=true --result=dp_get_cfg_response is DpTelegramGetCfgResponse --case="Fdl to dp (get cfg response)"

  // Check Config //
  raw_chk_cfg_request := #[0x68, 0x07, 0x07, 0x68, 0x94, 0x82, 0x6D, 0x3E, 0x3E, 0x9F, 0xA0, 0x3e, 0x16]
  fdl_chk_cfg_request := FdlTelegram.byte_array_to_fdl raw_chk_cfg_request
  dp_chk_cfg_request := DpTelegram.fdl_to_dp fdl_chk_cfg_request
  compare_test --expected=true --result=dp_chk_cfg_request is DpTelegramChkCfg --case="Fdl to dp (chk cgf request)"

  // Parameterization //
  raw_set_prm_request := #[0x68, 0x0C, 0x0C, 0x68, 0x94, 0x82, 0x6D, 0x3D, 0x3E, 0x80, 0x01, 0x01, 0x00, 0x06, 0xD1, 0x00, 0x57, 0x16]
  fdl_set_prm_request := FdlTelegram.byte_array_to_fdl raw_set_prm_request
  dp_set_prm_request := DpTelegram.fdl_to_dp fdl_set_prm_request
  compare_test --expected=true --result= dp_set_prm_request is DpTelegramSetPrmRequest --case="Fdl to dp (chk set prm request)"

test_get_du:
  dp_set_prm_request := DpTelegramSetPrmRequest --da=20 --sa=2 --ident_number=0x06D1 --group_indent=0 --user_prm=#[0x44]
  compare_test --expected=0x80 --result=dp_set_prm_request.get_du[0] --case="Get du (station status)"
  compare_test --expected=0x01 --result=dp_set_prm_request.get_du[1] --case="Get du (wd fact 1)"
  compare_test --expected=0x01 --result=dp_set_prm_request.get_du[2] --case="Get du (wd fact 2)"
  compare_test --expected=0x00 --result=dp_set_prm_request.get_du[3] --case="Get du (min TSDR)"
  compare_test --expected=0x06 --result=dp_set_prm_request.get_du[4] --case="Get du (ident number high)"
  compare_test --expected=0xD1 --result=dp_set_prm_request.get_du[5] --case="Get du (ident number low)"
  compare_test --expected=0x00 --result=dp_set_prm_request.get_du[6] --case="Get du (group indent)"
  compare_test --expected=0x44 --result=dp_set_prm_request.get_du[7] --case="Get du (user prm byte 0)"

  dp_data_exchange_response := DpTelegramDataExchangeResponse --da=2 --sa=20 --du=#[0x10, 0x20, 0x30, 0x40]
  compare_test --expected=0x10 --result=dp_data_exchange_response.get_du[0] --case="Get du byte 0"
  compare_test --expected=0x20 --result=dp_data_exchange_response.get_du[1] --case="Get du byte 1"
  compare_test --expected=0x30 --result=dp_data_exchange_response.get_du[2] --case="Get du byte 2"
  compare_test --expected=0x40 --result=dp_data_exchange_response.get_du[3] --case="Get du byte 3"

  raw_get_cfg_response := #[0x68, 0x07, 0x07, 0x68, 0x82, 0x94, 0x08, 0x3E, 0x3B, 0x9F, 0xA0, 0xD6, 0x16]
  fdl_get_cfg_response := FdlTelegram.byte_array_to_fdl raw_get_cfg_response
  dp_get_cfg_response := DpTelegram.fdl_to_dp fdl_get_cfg_response
  compare_test --expected=0x9F --result=dp_get_cfg_response.get_du[0] --case="Get du byte 0"
  compare_test --expected=0xA0 --result=dp_get_cfg_response.get_du[1] --case="Get du byte 1"

test_diagnose_response_functions:
  raw_diagnose_response_one := #[0x00, 0x04, 0x80, 0xff, 0x06, 0xd1]
  dp_diagnose_response_one := DpTelegramDiagnoseResponse --da=2 --sa=20 --du=raw_diagnose_response_one
  compare_test --expected=false --result=dp_diagnose_response_one.station_not_exists --case="station non existent"
  compare_test --expected=false --result=dp_diagnose_response_one.station_not_ready --case="station not ready"
  compare_test --expected=false --result=dp_diagnose_response_one.cfg_fault --case="cfg fault"
  compare_test --expected=false --result=dp_diagnose_response_one.has_ext_diag --case="ext diag"
  compare_test --expected=false --result=dp_diagnose_response_one.is_not_supported --case="not supported"
  compare_test --expected=false --result=dp_diagnose_response_one.prm_fault --case="prm fault"
  compare_test --expected=false --result=dp_diagnose_response_one.master_lock --case="master lock"
  compare_test --expected=false --result=dp_diagnose_response_one.prm_required --case="prm required"
  compare_test --expected=false --result=dp_diagnose_response_one.watchdog_on --case="watchdog on"
  compare_test --expected=false --result=dp_diagnose_response_one.freeze_mode --case="freeze mode"
  compare_test --expected=false --result=dp_diagnose_response_one.sync_mode --case="sync mode"
  compare_test --expected=true --result=dp_diagnose_response_one.is_ready_for_data_exchange --case="is ready for data exchange"

  raw_diagnose_response_two := #[0xFF, 0xFF, 0x80, 0xff, 0x06, 0xd1]
  dp_diagnose_response_two := DpTelegramDiagnoseResponse --da=2 --sa=20 --du=raw_diagnose_response_two
  compare_test --expected=true --result=dp_diagnose_response_two.station_not_exists --case="station non existent"
  compare_test --expected=true --result=dp_diagnose_response_two.station_not_ready --case="station not ready"
  compare_test --expected=true --result=dp_diagnose_response_two.cfg_fault --case="cfg fault"
  compare_test --expected=true --result=dp_diagnose_response_two.has_ext_diag --case="ext diag"
  compare_test --expected=true --result=dp_diagnose_response_two.is_not_supported --case="not supported"
  compare_test --expected=true --result=dp_diagnose_response_two.prm_fault --case="prm fault"
  compare_test --expected=true --result=dp_diagnose_response_two.master_lock --case="master lock"
  compare_test --expected=true --result=dp_diagnose_response_two.prm_required --case="prm required"
  compare_test --expected=true --result=dp_diagnose_response_two.watchdog_on --case="watchdog on"
  compare_test --expected=true --result=dp_diagnose_response_two.freeze_mode --case="freeze mode"
  compare_test --expected=true --result=dp_diagnose_response_two.sync_mode --case="sync mode"
  compare_test --expected=false --result=dp_diagnose_response_two.is_ready_for_data_exchange --case="is ready for data exchange"

main:
  test_parameterize_request
  test_get_cfg_telegram
  test_chk_cfg_telegram
  test_fdl_to_dp
  test_get_du
  test_diagnose_response_functions
