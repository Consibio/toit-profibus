// PROFIBUS DP - Layer 2 - Fieldbus Data Link (FDL)

class FdlTelegram:

  /**
  Start delimiter for the no data FDL telegram
  */
  static SD1 ::= 0x10
  
  /**
  Start delimiter for the variable data FDL telegram
  */
  static SD2 ::= 0x68
  
  /**
  Start delimiter for the fixed data FDL telegram
  */  
  static SD3 ::= 0xA2
  
  /**
  Start delimiter for the master-to-master token FDL telegram
  */  
  static SD4 ::= 0xDC
  
  /**
  Start delimiter for the short acknowledgement FDL telegram
  */  
  static SC ::= 0xE5

  /** 
  End delimiter
  */ 
  static ED ::= 0x16

  /**
  The address extention bit used with telegrams using DSAP/SSAP.
  */
  static ADDRESS_EXT ::= 0x80

  /**
  Function code value if first request
  */
  static FC_FIRST_REQUEST ::= 0x6D

  /**
  Function code for request
  */
  static FC_REQ ::= 0x40
  /**
  Function code for request telegrams (FC_REQ set).
  Send and request data with acknowledge. 
  */
  static FC_SRD_HI ::= 0x0D

  /**
  Function code for response telegrams (FC_REQ clear)
  Response FDL data low and send data ok. 
  */
  static FC_DL ::= 0x08

  sd/int // Start delimiter
  da/int? // Destination address
  sa/int? // Source address
  fc/int? // Function code
  dae/int? // Destination address extentions (DSAP)
  sae/int? // Source address extentions (SSAP)
  ed/int // End delimiter
  du/ByteArray? // Data unit
  have_le/bool // Does the FDL telegram have a length field?
  have_fcs/bool // Does the FDL telgram have a frame check sequence field?

  constructor --.sd --.have_le=false --.da --.sa --.fc --.dae --.sae --.du --.have_fcs=false .ed=ED:

  /**
  Calculates the lenght field for the FDL telegram. 
  Returns the lenght
  */
  calc_le -> int:
    da_sa_fc := 3
    le/int := 0
    if dae != null and sae != null:
      le = #[dae].size + #[sae].size + da_sa_fc + du.size
    else:
      le = da_sa_fc + du.size
    return le

  /**
  Calculates the frame check sequence (FCS) for the FDL telegram.
  Returns the FCS. 
  */
  static calc_fcs data/ByteArray -> int:
    fcs/int := 0
    data.do: | data_element |
      fcs += data_element
    return fcs & 0xFF

  /**
  Calculates the size of the FDL telegram.
  Returns a byte array of the corect size, otherwise throw error. 
  */
  calc_byte_array_size -> ByteArray?:
    if sd == SD1:
      return ByteArray (6)
    else if sd == SD2:
      if dae != null and sae != null:
        return ByteArray (11 + du.size)
      else:
        return ByteArray (9 + du.size)
    else if sd == SD3:
      return ByteArray (6 + du.size)
    else if sd == SD4:
      return ByteArray (3)
    else:
      throw "Invalid start delimiter"

  /**
  Converts a byte array to a FDL telegram given the specified input byte array. 
  Returns the FDL telegram.
  Throws errors if there are errors in the recived input byte array. 
  */
  static byte_array_to_fdl input/ByteArray -> FdlTelegram:
    startDelimiter := input[0]
    fdlTelegram/FdlTelegram? := null
    if startDelimiter == SD1:
      if input.size != 6:
        throw "Invalid FDL packet length"
      if input[5] != ED:
        throw "Invalid End Delimiter"
      if input[4] != (calc_fcs input[1..4]):
        throw "Invalid checksum"
      input_da := input[1] 
      input_sa := input[2]
      input_fc := input[3]
      fdlTelegram = FdlTelegramNoData --da=input_da --sa=input_sa --fc=input_fc
      return fdlTelegram

    if startDelimiter == SD2: 
      input_le := input[1]
      if input_le != input[2]:
        throw "Invalid length repetition"
      if input_le < 3 or input_le > 249:
        throw "Invalid length"
      input_sd := input[3]
      if input_sd != startDelimiter:
        throw "Invalid repeated SD"
      input_ed := input[input.size-1]
      if input_ed != ED:
        throw "Invalid End Delimiter"
      if input[input.size-2] != (calc_fcs input[4..input.size-2]):
        throw "Invalid checksum"
      input_du := input[7..input.size-2]
      /*
      if input_du.size != 0 and input_du != input_le - 3:
        print input_du
        print input_du.size
        throw "FDL packet shorter than LE"
      */
      input_da := input[4]
      input_sa := input[5]
      input_fc := input[6]
      input_dsap/int? := null
      input_ssap/int? := null
      da_extension_is_set/bool := (input_da & ADDRESS_EXT != 0)
      sa_extension_is_set/bool := (input_sa & ADDRESS_EXT != 0)
      if da_extension_is_set and sa_extension_is_set:
        input_da ^= ADDRESS_EXT
        input_sa ^= ADDRESS_EXT
        input_dsap = input[7]
        input_ssap = input[8]
        input_du = input[9..input.size-2]
      fdlTelegram = FdlTelegramVariableData --da=input_da --sa=input_sa --fc=input_fc --dae=input_dsap --sae=input_ssap --du=input_du
      return fdlTelegram

    if startDelimiter == SD3:
    // Fixed 8 data bytes telegram
      if input.size != 14:
        throw "Invalid Fixed length data FDL telegram"
      if input[13] != ED:
        throw "Invalid End Delimiter"
      if input[input.size-2] != (calc_fcs input[1..input.size-2]):
        throw "Invalid checksum"
      input_da := input[1] 
      input_sa := input[2]
      input_fc := input[3]
      input_du := input[4..input.size-2]
      fdlTelegram = FdlTelegramFixedData --da=input_da --sa=input_sa --fc=input_fc --du=input_du
      return fdlTelegram

    if startDelimiter == SD4:
      throw "Token passing: Not yet implemented"

    if startDelimiter == SC:
      if input.size != 1:
        throw "Invalid Short Acknowledge FDL telegram"
      fdlTelegram = FdlTelegramShortAcknowledge
      return fdlTelegram
    
    // If FDLtelegram is not set, the SD does not match. 
    else:
      throw "Invalid start delimiter"
 
  /**
  Converts a FDL telegram to a byte array. 
  Return the byte array. 
  */
  to_byte_array -> ByteArray:
    data := calc_byte_array_size
    pos := 0

    if have_le:
      data[pos++] += sd
      le := calc_le
      data[pos++] = le
      data[pos++] = le

    data[pos++] = sd

    if dae != null and sae != null:
      data[pos++] = da | FdlTelegram.ADDRESS_EXT
      data[pos++] = sa | FdlTelegram.ADDRESS_EXT
    else:
      data[pos++] = da
      data[pos++] = sa

    if fc != null:
      data[pos++] = fc

    if sd == SD2:
      if dae != null and sae != null:
        data[pos++] = dae
        data[pos++] = sae

    if du.size != 0:
      du.do: | du_byte | 
        data[pos++] = du_byte

    if have_fcs:
      fcs/int := ?
      if have_le:
        fcs = calc_fcs data[4..]
      else:
        fcs = calc_fcs data[1..]
      data[pos++] = fcs
  
    data[pos++] = ed

    return data

/**
The no data FDL telegram type
*/
class FdlTelegramNoData extends FdlTelegram:
  constructor --da/int --sa/int --fc/int:
    super --sd=FdlTelegram.SD1 --da=da --sa=sa --fc=fc --dae=null --sae=null --du=null --have_fcs=true

/**
The variable data FDL telegram type
*/
class FdlTelegramVariableData extends FdlTelegram:
  constructor --da/int --sa/int --fc/int --dae/int? --sae/int? --du/ByteArray?:
    super --sd=FdlTelegram.SD2 --have_le=true --da=da --sa=sa --fc=fc --dae=dae --sae=sae --du=du --have_fcs=true

/**
The fixed data FDL telegram type
*/
class FdlTelegramFixedData extends FdlTelegram:
  constructor --da/int --sa/int --fc/int --du/ByteArray?:
    super --sd=FdlTelegram.SD3 --da=da --sa=sa --fc=fc --dae=null --sae=null --du=du --have_fcs=true
  
/**
The short acknowledge FDL telegram type
*/
class FdlTelegramShortAcknowledge extends FdlTelegram:
  constructor:
    super --sd=FdlTelegram.SC --da=null --sa=null --fc=null --dae=null --sae=null --du=null
