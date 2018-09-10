object frmTSCANDemo: TfrmTSCANDemo
  Left = 0
  Top = 0
  Caption = 'TSCAN Demo'
  ClientHeight = 555
  ClientWidth = 877
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlControl: TPanel
    Left = 0
    Top = 0
    Width = 877
    Height = 41
    Align = alTop
    ShowCaption = False
    TabOrder = 0
    object btnConnect: TButton
      Left = 16
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 104
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Disconnect'
      Enabled = False
      TabOrder = 1
    end
  end
  object stat: TStatusBar
    Left = 0
    Top = 536
    Width = 877
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object page: TPageControl
    Left = 0
    Top = 41
    Width = 877
    Height = 495
    ActivePage = shtTXRX
    Align = alClient
    TabOrder = 2
    object shtTXRX: TTabSheet
      Caption = 'CAN TX / RX'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblType: TLabel
        Left = 24
        Top = 16
        Width = 28
        Height = 13
        Caption = 'Type:'
      end
      object lblIdentifier: TLabel
        Left = 24
        Top = 43
        Width = 48
        Height = 13
        Caption = 'Identifier:'
      end
      object lblDLC: TLabel
        Left = 24
        Top = 69
        Width = 23
        Height = 13
        Caption = 'DLC:'
      end
      object lblData: TLabel
        Left = 24
        Top = 96
        Width = 27
        Height = 13
        Caption = 'Data:'
      end
      object cbStandard: TComboBox
        Left = 92
        Top = 13
        Width = 245
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'CAN Standard Frame (11 bits Identifier)'
        Items.Strings = (
          'CAN Standard Frame (11 bits Identifier)'
          'CAN Extended Frame (29 bits Identifier)')
      end
      object chkRemote: TCheckBox
        Left = 400
        Top = 15
        Width = 97
        Height = 17
        Caption = 'Remote Frame'
        TabOrder = 1
      end
      object edtIdentifier: TEdit
        Left = 92
        Top = 40
        Width = 245
        Height = 21
        TabOrder = 2
        Text = '0x123'
      end
      object cbDLC: TComboBox
        Left = 92
        Top = 66
        Width = 245
        Height = 21
        Style = csDropDownList
        ItemIndex = 8
        TabOrder = 3
        Text = '8'
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8')
      end
      object edtData0: TEdit
        Left = 92
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 4
        Text = '0x12'
      end
      object edtData1: TEdit
        Left = 159
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 5
        Text = '0x34'
      end
      object edtData2: TEdit
        Left = 226
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 6
        Text = '0x56'
      end
      object edtData3: TEdit
        Left = 293
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 7
        Text = '0x78'
      end
      object edtData4: TEdit
        Left = 360
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 8
        Text = '0x90'
      end
      object edtData5: TEdit
        Left = 427
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 9
        Text = '0xAB'
      end
      object edtData6: TEdit
        Left = 494
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 10
        Text = '0xCD'
      end
      object edtData7: TEdit
        Left = 561
        Top = 93
        Width = 61
        Height = 21
        Alignment = taCenter
        TabOrder = 11
        Text = '0xEF'
      end
      object btnTX1: TButton
        Left = 92
        Top = 123
        Width = 128
        Height = 25
        Caption = 'Send On Channel 1'
        Enabled = False
        TabOrder = 12
        OnClick = btnTX1Click
      end
      object btnTX2: TButton
        Left = 226
        Top = 123
        Width = 128
        Height = 25
        Caption = 'Send On Channel 2'
        Enabled = False
        TabOrder = 13
        OnClick = btnTX2Click
      end
      object lstCAN: TListView
        AlignWithMargins = True
        Left = 3
        Top = 160
        Width = 863
        Height = 304
        Margins.Top = 160
        Align = alClient
        Columns = <
          item
            Caption = 'Counter'
            Width = 80
          end
          item
            Caption = 'Timestamp (s)'
            Width = 120
          end
          item
            Alignment = taCenter
            Caption = 'Channel'
            Width = 60
          end
          item
            Alignment = taCenter
            Caption = 'Dir'
          end
          item
            Caption = 'Identifier'
            Width = 120
          end
          item
            Alignment = taCenter
            Caption = 'Type'
            Width = 120
          end
          item
            Alignment = taCenter
            Caption = 'DLC'
          end
          item
            AutoSize = True
            Caption = 'Data (Hex)'
            MinWidth = 100
          end>
        FlatScrollBars = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 14
        ViewStyle = vsReport
        ExplicitLeft = 312
        ExplicitWidth = 250
        ExplicitHeight = 150
      end
    end
  end
end
