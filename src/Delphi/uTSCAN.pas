unit uTSCAN;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

const
  DLL_TSCAN = 'libTSCAN.dll';
  // CAN message properties
  MASK_CANProp_DIR_TX  = $01;
  MASK_CANProp_REMOTE  = $02;
  MASK_CANProp_EXTEND  = $04;
  MASK_CANProp_ERROR   = $80;

type
  u8 = UInt8;
  s8 = Int8;
  u16 = UInt16;
  s16 = Int16;
  u32 = UInt32;
  s32 = Int32;
  u64 = UInt64;
  s64 = Int64;
  pu8 = ^u8;
  ps8 = ^s8;
  pu16 = ^u16;
  ps16 = ^s16;
  pu32 = ^u32;
  ps32 = ^s32;
  pu64 = ^u64;
  ps64 = ^s64;
  u8x8 = array [0..7] of u8;
  u16x8 = array [0..7] of u16;
  u8array = array of u8;

  // CAN frame definition = 24 B
  PCAN = ^TCAN;
  TCAN = packed record
    FIdxChn: u8;           // channel index starting from 0
    FProperties: u8;       // default 0, masked status:
                           // [7] 0-send normal frame, 1-send error frame
                           // [6-2] tbd
                           // [1] 0-std frame, 1-extended frame
                           // [0] 0-data frame, 1-remote frame
    FDLC: u8;              // dlc from 0 to 8
    FReserved: u8;         // reserved to keep alignment
    FIdentifier: u32;      // CAN identifier
    FData: u8x8;           // 8 data bytes to send
    FTimeUS: u64;          // timestamp in us
    procedure SetStdId(const AId: UInt32; const ADLC: UInt32);
    procedure SetExtId(const AId: UInt32; const ADLC: UInt32);
    function GetTX: Boolean;
    function GetData: boolean;
    function GetStd: Boolean;
    function GetErr: Boolean;
    procedure SetTX(const AValue: Boolean);
    procedure SetData(const AValue: Boolean);
    procedure SetStd(const AValue: Boolean);
    procedure SetErr(const AValue: Boolean);
    // properties
    property IsTX: Boolean read GetTX write SetTX;
    property IsData: boolean read GetData write SetData;
    property IsStd: boolean read GetStd write SetStd;
    property IsErr: Boolean read GetErr write SetErr;
  end;

  TCANQueueEvent = procedure(const AData: PCAN); stdcall;
  TFirmwareUpdateCallback = procedure(const AStatus: u32; const APercentage100: Single); stdcall; // FIRM_UPDATE_COMPLETE, FIRM_UPDATE_FAILED
  TTSCANConnectedCallback = procedure(const ADevicehandle: u32); stdcall;

// Device management -----------------------------------------------------------
function ScanTSCANDevices(ADeviceCount: pu32): u32; stdcall;  external DLL_TSCAN;
function GetTSCANInfo(
  const ADeviceIndex: u32;
  AFManufacturer: PpansiChar;
  AFProduct: pPansiChar;
  AFSerial: pPansiChar
): u32; stdcall;  external DLL_TSCAN;
function ConnectTSCAN(const ADeviceSerial: PAnsiChar; AHandle: pu32): u32; stdcall;  external DLL_TSCAN;
function DisconnectAllTSCAN: u32; stdcall;  external DLL_TSCAN;
function DisconnectTSCANBySerial(const ADeviceSerial: PAnsiChar): u32; stdcall;  external DLL_TSCAN;
function DisconnectTSCANByDevice(const ADeviceHandle: u32): u32; stdcall;  external DLL_TSCAN;
function GetTSCANErrorDescription(const ACode: u32; ADesc: PPAnsiChar): u32; stdcall;  external DLL_TSCAN;
function RegisterOnConnectedCallback(const ACallback: TTSCANConnectedCallback): u32; stdcall;  external DLL_TSCAN;
function RegisterOnDisconnectedCallback(const ACallback: TTSCANConnectedCallback): u32; stdcall;  external DLL_TSCAN;
function UnregisterOnConnectedCallback(const ACallback: TTSCANConnectedCallback): u32; stdcall;  external DLL_TSCAN;
function UnregisterOnDisconnectedCallback(const ACallback: TTSCANConnectedCallback): u32; stdcall;  external DLL_TSCAN;
procedure UnregisterOnConnectedCallbacks; stdcall;  external DLL_TSCAN;
procedure UnregisterOnDisconnectedCallbacks; stdcall;  external DLL_TSCAN;

// API implementation ----------------------------------------------------------
function RegisterCANRecvCallback(const ADeviceHandle: u32; const ACallback: TCANQueueEvent): u32; stdcall;  external DLL_TSCAN;
function SendCANSync(const ADeviceHandle: u32; const ACAN: PCAN; const ATimeoutS: u32): u32; stdcall;  external DLL_TSCAN;
function SendCANAsync(const ADeviceHandle: u32; const ACAN: PCAN): u32; stdcall;  external DLL_TSCAN;
function StopPendingOperations: u32; stdcall;  external DLL_TSCAN;

implementation

{ TCAN }

function TCAN.GetData: boolean;
begin
  Result := (FProperties and MASK_CANProp_REMOTE) = 0;

end;

function TCAN.GetErr: Boolean;
begin
  Result := (FProperties and MASK_CANProp_ERROR) <> 0;

end;

function TCAN.GetStd: Boolean;
begin
  Result := (FProperties and MASK_CANProp_EXTEND) = 0;

end;

function TCAN.GetTX: boolean;
begin
  Result := (FProperties and MASK_CANProp_DIR_TX) <> 0;

end;

procedure TCAN.SetData(const AValue: Boolean);
begin
  if avalue then begin
    FProperties := FProperties and (not MASK_CANProp_REMOTE);
  end else begin
    FProperties := FProperties or MASK_CANProp_REMOTE;
  end;

end;

procedure TCAN.SetErr(const AValue: Boolean);
begin
  if not AValue then begin
    FProperties := FProperties and (not MASK_CANProp_ERROR);
  end else begin
    FProperties := FProperties or MASK_CANProp_ERROR;
  end;

end;

procedure TCAN.SetExtId(const AId, ADLC: UInt32);
begin
  FIdxChn := 0;
  FIdentifier := AId;
  FDLC := ADLC;
  FProperties := 0;
  SetTX(True);
  SetStd(False);
  SetData(True);
  PUInt64(@FData[0])^ := 0;

end;

procedure TCAN.SetStd(const AValue: Boolean);
begin
  if avalue then begin
    FProperties := FProperties and (not MASK_CANProp_EXTEND);
  end else begin
    FProperties := FProperties or MASK_CANProp_EXTEND;
  end;

end;

procedure TCAN.SetStdId(const AId, ADLC: UInt32);
begin
  FIdxChn := 0;
  FIdentifier := AId;
  FDLC := ADLC;
  FProperties := 0;
  SetTX(True);
  SetStd(True);
  SetData(True);
  PUInt64(@FData[0])^ := 0;

end;

procedure TCAN.SetTX(const AValue: Boolean);
begin
  if avalue then begin
    FProperties := FProperties or MASK_CANProp_DIR_TX;
  end else begin
    FProperties := FProperties and (not MASK_CANProp_DIR_TX);
  end;

end;

end.
