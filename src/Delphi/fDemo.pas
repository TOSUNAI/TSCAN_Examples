unit fDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  uTSCAN;

type
  TfrmTSCANDemo = class(TForm)
    pnlControl: TPanel;
    stat: TStatusBar;
    page: TPageControl;
    shtTXRX: TTabSheet;
    btnConnect: TButton;
    btnDisconnect: TButton;
    cbStandard: TComboBox;
    lblType: TLabel;
    chkRemote: TCheckBox;
    edtIdentifier: TEdit;
    lblIdentifier: TLabel;
    lblDLC: TLabel;
    cbDLC: TComboBox;
    lblData: TLabel;
    edtData0: TEdit;
    edtData1: TEdit;
    edtData2: TEdit;
    edtData3: TEdit;
    edtData4: TEdit;
    edtData5: TEdit;
    edtData6: TEdit;
    edtData7: TEdit;
    btnTX1: TButton;
    btnTX2: TButton;
    lstCAN: TListView;
    procedure btnConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnTX1Click(Sender: TObject);
    procedure btnTX2Click(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
  private
    FTSCANHandle: u32;
    FCounter: u32;

    procedure Log(const AStr: string);
    procedure AddCANData(const ACAN: PCAN);
    procedure InternalTXCAN(const AChannelIdx: Integer);
    procedure EnableUI(const AConnected: Boolean);
  public

  end;

var
  frmTSCANDemo: TfrmTSCANDemo;

procedure OnTSCANConnected(const ADevicehandle: u32); stdcall;
procedure OnTSCANDisconnected(const ADevicehandle: u32); stdcall;

implementation

uses
  System.Math;

{$R *.dfm}

procedure OnCANTXRX(const AData: PCAN); stdcall;
var
  c: TCAN;
begin
  c := adata^;
  // threaded, use UI sync method !
  TThread.Queue(
    nil,
    procedure begin
      frmTSCANDemo.AddCANData(@c);
    end
  );

end;

procedure TfrmTSCANDemo.AddCANData(const ACAN: PCAN);
var
  i, n: integer;
  itm: TListItem;
  s: string;
begin
  lstcan.Items.BeginUpdate;
  if lstCAN.Items.Count > 1000 then begin
    lstCAN.Items.Delete(0);
  end;
  itm := lstCAN.Items.Add;
  itm.Caption := FCounter.ToString;
  Inc(FCounter);
  itm.SubItems.Add(FloatToStrF(acan.FTimeUS / 1000000.0, ffFixed, 16, 6));
  itm.SubItems.Add((acan.FIdxChn+1).ToString);
  if acan.IsTX then begin
    itm.SubItems.Add('TX');
  end else begin
    itm.SubItems.Add('RX');
  end;
  if acan.IsStd then begin
    itm.SubItems.Add('0x' + acan.FIdentifier.ToHexString(3));
    if acan.IsData then begin
      itm.SubItems.Add('Std. Data');
    end else begin
      itm.SubItems.Add('Std. Remote');
    end;
  end else begin
    itm.SubItems.Add('0x' + acan.FIdentifier.ToHexString(8));
    if acan.IsData then begin
      itm.SubItems.Add('Ext. Data');
    end else begin
      itm.SubItems.Add('Ext. Remote');
    end;
  end;
  itm.SubItems.Add(acan.FDLC.ToString);
  if acan.IsData then begin
    n := Min(acan.FDLC, 8);
    s := '';
    for i:=0 to n-1 do begin
      s := s + IntToHex(acan.FData[i], 2) + ' ';
    end;
    itm.SubItems.Add(s);
  end else begin
    itm.SubItems.Add('');
  end;
  itm.MakeVisible(True);
  lstCAN.items.EndUpdate;

end;

procedure TfrmTSCANDemo.btnConnectClick(Sender: TObject);
begin
  ConnectTSCAN(nil, @FTSCANHandle);

end;

procedure TfrmTSCANDemo.btnDisconnectClick(Sender: TObject);
begin
  DisconnectAllTSCAN;

end;

procedure TfrmTSCANDemo.btnTX1Click(Sender: TObject);
begin
  InternalTXCAN(0);

end;

procedure TfrmTSCANDemo.btnTX2Click(Sender: TObject);
begin
  InternalTXCAN(1);

end;

procedure OnTSCANConnected(const ADevicehandle: u32);
begin
  frmTSCANDemo.Log('TSCAN connected');
  RegisterCANRecvCallback(ADevicehandle, OnCANTXRX);
  frmTSCANDemo.EnableUI(True);

end;

procedure OnTSCANDisconnected(const ADevicehandle: u32);
begin
  frmTSCANDemo.Log('TSCAN disconnected');
  frmTSCANDemo.EnableUI(False);

end;

procedure TfrmTSCANDemo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisconnectAllTSCAN;
  UnregisterOnConnectedCallbacks;
  UnregisterOnDisconnectedCallbacks;

end;

procedure TfrmTSCANDemo.FormCreate(Sender: TObject);
begin
  RegisterOnConnectedCallback(OnTSCANConnected);
  RegisterOnDisconnectedCallback(OnTSCANDisconnected);

end;

procedure TfrmTSCANDemo.InternalTXCAN(const AChannelIdx: Integer);
var
  c: TCAN;
  id, dlc: integer;
begin
  id := StrToIntDef(edtIdentifier.Text, 0);
  dlc := cbDLC.ItemIndex;
  if cbStandard.ItemIndex = 0 then begin
    c.SetStdId(id, dlc);
  end else begin
    c.SetExtId(id, dlc);
  end;
  if chkRemote.Checked then begin
    c.SetData(False);
  end else begin
    c.SetData(True);
  end;
  c.FData[0] := StrToIntDef(edtData0.Text, 0);
  c.FData[1] := StrToIntDef(edtData1.Text, 0);
  c.FData[2] := StrToIntDef(edtData2.Text, 0);
  c.FData[3] := StrToIntDef(edtData3.Text, 0);
  c.FData[4] := StrToIntDef(edtData4.Text, 0);
  c.FData[5] := StrToIntDef(edtData5.Text, 0);
  c.FData[6] := StrToIntDef(edtData6.Text, 0);
  c.FData[7] := StrToIntDef(edtData7.Text, 0);
  SendCANAsync(FTSCANHandle, @c);

end;

procedure TfrmTSCANDemo.Log(const AStr: string);
begin
  stat.SimpleText := TimeToStr(Now) + ': ' + astr;

end;

procedure TfrmTSCANDemo.EnableUI(const AConnected: Boolean);
begin
  btnConnect.Enabled := not AConnected;
  btnDisconnect.Enabled := aconnected;
  btntx1.Enabled := aconnected;
  btnTX2.Enabled := AConnected;

end;

end.
