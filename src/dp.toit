// PROFIBUS DP - Layer 7

import .fdl

abstract class DpTelegram:

  // Source Service Access Point Numbers
  static SSAP_MS0 ::= 0x3E // Master to slave
  static SSAP_MS1 ::= 0x33 // DP Master Class 1 to slave
  static SSAP_MS2 ::= 0x32 // DP Master Class 2 to slave
  static SSAP_MM ::= 0x36 // Master to master

  // Destination Service Access Point Numbers
  static DSAP_RESOURCE_MAN ::= 0x31
  static DSAP_ALARM ::= 0x32
  static DSAP_SERVER ::= 0x33
  static DSAP_EXT_USER_PRM ::= 0x35
  static DSAP_SET_SLAVE_ADDRESS ::= 0x37
  static DSAP_READ_INPUT ::= 0x38
  static DSAP_READ_OUTPUT ::= 0x39
  static DSAP_GLOBAL_CONTROL ::= 0x3A
  static DSAP_SLAVE_DIAG ::= 0x3C
  static DSAP_GET_CFG ::= 0x3B 
  static DSAP_SLAVE_SET_PRM ::= 0x3D
  static DSAP_CHECK_CFG ::=  0x3E
  
  /**
  Destination address
  */
  da/int?

  /**
  Source address
  */
  sa/int?

  /**
  Function code
  */
  fc/int?

  /**
  Destination service access point
  */
  dsap/int?

  /**
  Source service access point
  */
  ssap/int?

  /**
  Data unit
  */
  du/ByteArray

  constructor --.da --.sa --.fc --.dsap --.ssap --.du:

  /**
  Implemented in each subclass.
  Converts a DP telegram to a FDL telegram. 
  */
  abstract dp_to_fdl_telegram -> FdlTelegram

  /**
  Returns the data unit from the DP telegram
  */
  get_du -> ByteArray:
    return du
  
  /**
  Converts FDL telegrams to DP telegrams by using the specified fdl_telegram. 
  Returns the corresponding DP telegram from the FDL telegram.
  Throw error if the FDL telegram did not match any known DP telegram. 
  */
  static fdl_to_dp fdl_telegram/FdlTelegram -> DpTelegram?:
    // --- Telegrams with no DSAP/SSAP --- //
    if fdl_telegram is FdlTelegramShortAcknowledge:
      return DpTelegramShortAcknowledgeResponse

    if fdl_telegram is FdlTelegramNoData:
      return DpTelegramNoDataResponse 
        --da=fdl_telegram.da 
        --sa=fdl_telegram.sa 
        --fc=fdl_telegram.fc

    if not fdl_telegram.dae:
      if fdl_telegram.sae:
        throw "TELEGRAM WITH SSAP, BUT WITHOUT DSAP"
      if (fdl_telegram.fc & FdlTelegram.FC_REQ != 0):
        return DpTelegramDataExchangeRequest 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --du=fdl_telegram.du
      else:
        return DpTelegramDataExchangeResponse 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --du=fdl_telegram.du
    if not fdl_telegram.sae:
      throw "TELEGRAM WITH DSAP, BUT WITHOUT SSAP"

    // --- Telegrams with DSAP/SSAP --- //
    if fdl_telegram.sae == SSAP_MS0:
      if fdl_telegram.dae == DSAP_SLAVE_DIAG:
        return DpTelegramDiagnoseRequest 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae
          --ssap=fdl_telegram.sae
      else if fdl_telegram.dae == DSAP_SLAVE_SET_PRM:
        return DpTelegramSetPrmRequest 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae 
          --ssap=fdl_telegram.sae 
          --station_status=fdl_telegram.du[0]
          --wd_fact_1=fdl_telegram.du[1]
          --wd_fact_2=fdl_telegram.du[2]
          --min_TSDR=fdl_telegram.du[3]
          --ident_number=fdl_telegram.du[4]
          --group_indent=fdl_telegram.du[5]
          --user_prm=fdl_telegram.du[6..]
      else if fdl_telegram.dae == DSAP_GET_CFG:
        return DpTelegramGetCfgRequest
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae 
          --ssap=fdl_telegram.sae 
      else if fdl_telegram.dae == DSAP_CHECK_CFG:
        return DpTelegramChkCfgRequest
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae 
          --ssap=fdl_telegram.sae 
          --du=fdl_telegram.du
      else:
        throw "UNKNOWN DSAP"
    else if fdl_telegram.dae == SSAP_MS0:
      if fdl_telegram.sae == DSAP_SLAVE_DIAG:
        return DpTelegramDiagnoseResponse 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae 
          --ssap=fdl_telegram.sae 
          --du=fdl_telegram.du
      else if fdl_telegram.sae == DSAP_GET_CFG:
        return DpTelegramGetCfgResponse 
          --da=fdl_telegram.da 
          --sa=fdl_telegram.sa 
          --fc=fdl_telegram.fc 
          --dsap=fdl_telegram.dae 
          --ssap=fdl_telegram.sae 
          --du=fdl_telegram.du
      else:
        throw "UNKNOWN SSAP"
    else:
      throw "UNKNOWN SSAP OR DSAP"

// --- REQUESTS --- //
/**
Diagnose request DP telegram
*/
class DpTelegramDiagnoseRequest extends DpTelegram:
  constructor --da/int --sa/int --fc/int=(FdlTelegram.FC_SRD_HI | FdlTelegram.FC_REQ) --dsap/int=DpTelegram.DSAP_SLAVE_DIAG --ssap/int=DpTelegram.SSAP_MS0:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=#[]

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Set parameters request DP telegram
*/
class DpTelegramSetPrmRequest extends DpTelegram:
  // -- STATION STATUS -- //
  static STATION_WATCH_DOG_ON ::= 0x08	// Set this bit to active watchdog
  static STATION_FREEZE_REQUEST ::= 0x10	// Set this bit to request freeze mode
  static STATION_SYNC_REQUEST ::= 0x20	// Set this bit to request sync mode
  static STATION_UNLOCK_REQUEST ::= 0x40	// See below
  static STATION_LOCK_REQUEST ::= 0x80 // See below
  // If STATION_LOCK_REQUEST = 0 and STATION_UNLOCK_REQUEST = 0, the minTSDR parameter may be changed, all other parameters remain unchanged
  // If STATION_LOCK_REQUEST = 0 and STATION_UNLOCK_REQUEST = 1, DP slave is unlocked/released for other masters
  // If STATION_LOCK_REQUEST = 1 and STATION_UNLOCK_REQUEST = 0, DP slave locked for other masters. All parameters are accepted and can be carried over except minTSDR=0
  // If STATION_LOCK_REQUEST = 1 and STATION_UNLOCK_REQUEST = 1, DP slave is unlocked/relased for other masters

  // -- FIRST DPv1 USER_PRM_DATA BYTE (DPv1 OR LATER ONLY) -- //
  static DPV1PRM0_R0 ::= 0x01	// Reserved bit 0
  static DPV1PRM0_R1 ::= 0x02	// Reserved bit 1
  static DPV1PRM0_WD1MS ::= 0x04	// 1 ms watchdog base.
  static DPV1PRM0_R3 ::= 0x08	// Reserved bit 3
  static DPV1PRM0_R4 ::= 0x10	// Reserved bit 4
  static DPV1PRM0_PUBL ::= 0x20	// Run as publisher
  static DPV1PRM0_FAILSAFE ::= 0x40	// Fail_Safe mode
  static DPV1PRM0_V1MODE ::= 0x80	// DPv1 mode enable

  // -- SECOND DPv1 USER_PRM_DATA BYTE (DPv1 OR LATER ONLY) -- //
  static DPV1PRM1_REDCFG ::= 0x01	// Reduced Chk_Cfg
  static DPV1PRM1_R1 ::= 0x02	// Reserved bit 1
  static DPV1PRM1_ALRMUPD ::= 0x04	// Alarm: update
  static DPV1PRM1_ALRMSTAT ::= 0x08	// Alarm: status
  static DPV1PRM1_ALRMVEND ::= 0x10	// Alarm: vendor specific
  static DPV1PRM1_ALRMDIAG ::= 0x20	// Alarm: diagnostic
  static DPV1PRM1_ALRMPROC ::= 0x40	// Alarm: process
  static DPV1PRM1_ALRMPLUG ::= 0x80	// Alarm: pull-plug

  // -- THIRD DPv1 USER_PRM_DATA BYTE (DPv1 OR LATER ONLY) -- //
  static DPV1PRM2_ALRMCNT_MASK ::= 0x07	// Alarm count mask
  static DPV1PRM2_ALRMCNT1 ::= 0x00	// 1 alarm in total
  static DPV1PRM2_ALRMCNT2 ::= 0x01	// 2 alarms in total
  static DPV1PRM2_ALRMCNT4 ::= 0x02	// 4 alarms in total
  static DPV1PRM2_ALRMCNT8 ::= 0x03	// 8 alarms in total
  static DPV1PRM2_ALRMCNT12 ::= 0x04	// 12 alarms in total
  static DPV1PRM2_ALRMCNT16 ::= 0x05	// 16 alarms in total
  static DPV1PRM2_ALRMCNT24	::= 0x06	// 24 alarms in total
  static DPV1PRM2_ALRMCNT32 ::= 0x07	// 32 alarms in total
  static DPV1PRM2_PRMBLK ::= 0x08	// Parameter block follows
  static DPV1PRM2_ISO ::= 0x10	// Isochronous mode
  static DPV1PRM2_R5 ::= 0x20	// Reserved bit 5
  static DPV1PRM2_R6 ::= 0x40	// Reserved bit 6
  static DPV1PRM2_REDUN ::= 0x80	// Redundancy commands on

  constructor --da/int --sa/int --fc/int=(FdlTelegram.FC_SRD_HI | FdlTelegram.FC_REQ) --dsap/int=DpTelegram.DSAP_SLAVE_SET_PRM --ssap/int=DpTelegram.SSAP_MS0
      --station_status/int=STATION_LOCK_REQUEST --wd_fact_1/int=1 --wd_fact_2/int=1 --min_TSDR/int=0 --ident_number/int --group_indent/int --user_prm/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=#[station_status, wd_fact_1, wd_fact_2, min_TSDR, (ident_number>>8) & 0xFF, ident_number & 0xFF, group_indent]+user_prm

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Get config request DP telegram
*/
class DpTelegramGetCfgRequest extends DpTelegram:
  constructor --da/int --sa/int --fc/int=(FdlTelegram.FC_SRD_HI | FdlTelegram.FC_REQ) --dsap/int=DpTelegram.DSAP_GET_CFG --ssap/int=DpTelegram.SSAP_MS0:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=#[]

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Check config request DP telegram
*/
class DpTelegramChkCfgRequest extends DpTelegram:
  constructor --da/int --sa/int --fc/int=(FdlTelegram.FC_SRD_HI | FdlTelegram.FC_REQ) --dsap/int=DpTelegram.DSAP_CHECK_CFG --ssap/int=DpTelegram.SSAP_MS0 --du/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=du

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Data exchange request DP telegram
*/
class DpTelegramDataExchangeRequest extends DpTelegram:
  constructor --da/int --sa/int --fc/int=(FdlTelegram.FC_SRD_HI | FdlTelegram.FC_REQ) --du/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=null --ssap=null --du=du

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

// --- RESPONSES --- //
/**
Diagnose response DP telegram
*/
class DpTelegramDiagnoseResponse extends DpTelegram:
  // Byte 0 - Flags
  static B0_STATION_NON_EXISTENT ::= 0x01 // Set to 1 by master if slave cannot be reaced over the line
  static B0_STATION_NOT_READY ::= 0x02 // Set by slave if slave is not ready for data exchange
  static B0_CFG_FAULT ::= 0x04 // Set by slave if it detects a mismatch in config data
  static B0_EXT_DIAG ::= 0x08 // Set by slave to indicate more slave specific diagnostic data
  static B0_NOT_SUPPORTED ::= 0x10 // Set by slave if reqested function or service is not supported
  static B0_INVALID_SLAVE_RESPONSE ::= 0x20 // Slave sets this bit to 0. Set to 1 by the master if it receive an implausible response from the slave
  static B0_PRM_FAULT ::= 0x40 // Set by slave if last parameter attempt was faulty
  static B0_MASTER_LOCK ::= 0x80 // Set by a class 1 master to indicate slave has been parameterized by another master. Set to 0 by slave

  // Byte 1 - Flags
  static B1_PRM_REQUIRED ::= 0x01 // Set by slave if it needs to be parameterized
  static B1_STATIC_DIAG ::= 0x02 // Static diagnostics. Slave sets this bit to cause the master to retrieve diganostic information until this bit is cleared
  static B1_ONE ::= 0x04 // Slave always set this bit to 1
  static B1_WATCHDOG_ON ::= 0x80 // Set by slave to indicate watchdog is active
  static B1_FREEZE_MODE ::= 0x10 // Set by slave after it has received the freeze control command
  static B1_SYNC_MODE ::= 0x20 // Set by slave after it has received a sync command
  static B1_RESERVED ::= 0x40 // Reserved by slave
  static B1_DEACTIVATED ::= 0x80 // Set by the master if slave has been marked inactive within the slave paramter set. Slave sets this bit to 0

  // Byte 2 - Flags
  // Bit 0-6 are reserved in byte 2
  static B2_EXT_DIAG_OVERFLOW ::= 0x80 // Set if there is more diagnostic information than specified in EXT_DIAG_DATA.

  byte_0/int? := null
  byte_1/int? := null
  byte_2/int? := null
  master_address/int? := null
  ident_number/int? := null

  constructor --da/int --sa/int --fc/int=FdlTelegram.FC_DL --dsap/int=DpTelegram.SSAP_MS0 --ssap/int=DpTelegram.DSAP_SLAVE_DIAG --du/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=du
    byte_0 = du[0]
    byte_1 = du[1]
    byte_2 = du[2]
    master_address = du[3]
    ident_number = (du[4] << 8) | du[5]

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

  /**
  Returns true if station does not exists, else return false. 
  */
  station_not_exists -> bool:
    return (byte_0 & B0_STATION_NON_EXISTENT) != 0

  /**
  Returns true if station/slave is not ready, else return false. 
  */
  station_not_ready -> bool:
    return (byte_0 & B0_STATION_NOT_READY) != 0

  /**
  Returns true if there was a mismatch in config data, else return false. 
  */
  cfg_fault -> bool:
    return (byte_0 & B0_CFG_FAULT) != 0

  /**
  Returns true if there is a diagnostic entry in the slave specific dianostic area, else return false. 
  */
  has_ext_diag -> bool:
    return (byte_0 & B0_EXT_DIAG) != 0

  /**
  Returns true if the requested service is not supported, else return false. 
  */
  is_not_supported -> bool:
    return (byte_0 % B0_NOT_SUPPORTED) != 0

  /**
  Returns true if the parameterization failed, else return false. 
  */
  prm_fault -> bool:
    return (byte_0 & B0_PRM_FAULT) != 0

  /**
  Returns true if the slave has been parameterized by other slave, else return false. 
  */
  master_lock -> bool:
    return (byte_0 & B0_MASTER_LOCK) != 0

  /**
  Returns true if the slave needs to be parameterized, else return false. 
  */
  prm_required -> bool: 
    return (byte_1 & B1_PRM_REQUIRED) != 0

  /**
  Returns true if the watchdog is on by the slave, else return false. 
  */
  watchdog_on -> bool:
    return (byte_1 & B1_WATCHDOG_ON) != 0

  /**
  Returns true if freeze mode is active, else return false. 
  */
  freeze_mode -> bool:
    return (byte_1 & B1_FREEZE_MODE) != 0

  /**
  Returns true if sync mode is active, else return false. 
  */
  sync_mode -> bool:
    return (byte_1 & B1_SYNC_MODE) != 0

  /**
  Returns true if the slave is ready for data exchange, else return false. 
  */
  is_ready_for_data_exchange -> bool:
    return ((byte_0 & (B0_STATION_NON_EXISTENT | B0_STATION_NOT_READY | B0_CFG_FAULT | B0_PRM_FAULT)) == 0 and (byte_1 & B1_PRM_REQUIRED) == 0)

/**
Get config response DP telegram
*/
class DpTelegramGetCfgResponse extends DpTelegram:
  constructor --da/int --sa/int --fc/int=FdlTelegram.FC_DL --dsap/int=DpTelegram.SSAP_MS0 --ssap/int=DpTelegram.DSAP_GET_CFG --du/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=dsap --ssap=ssap --du=du

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Data exchange response DP telegram
*/
class DpTelegramDataExchangeResponse extends DpTelegram:
  constructor --da/int --sa/int --fc/int=FdlTelegram.FC_DL --du/ByteArray:
    super --da=da --sa=sa --fc=fc --dsap=null --ssap=null --du=du
   
  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramVariableData --da=da --sa=sa --fc=fc --dae=dsap --sae=ssap --du=du

/**
Short acknowledge response DP telegram
*/
class DpTelegramShortAcknowledgeResponse extends DpTelegram:
  constructor:
    super --da=null --sa=null --fc=null --dsap=null --ssap=null --du=#[]

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramShortAcknowledge

/**
No data response DP telegram
*/
class DpTelegramNoDataResponse extends DpTelegram:
  constructor --da/int --sa/int --fc/int=FdlTelegram.FC_DL:
    super --da=da --sa=sa --fc=fc --dsap=null --ssap=null --du=#[]

  dp_to_fdl_telegram -> FdlTelegram:
    return FdlTelegramNoData --da=da --sa=sa --fc=fc
  