object Form1: TForm1
  Left = 245
  Top = 111
  Width = 535
  Height = 787
  Caption = ' Generate Microcode and ROM Dumps'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 527
    Height = 32
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    object GenEPROMSButton1: TButton
      Left = 419
      Top = 3
      Width = 102
      Height = 25
      Caption = 'Generate EPROMs'
      TabOrder = 0
      OnClick = GenEPROMSButton1Click
    end
    object DumpEPROMSButton1: TButton
      Left = 324
      Top = 3
      Width = 89
      Height = 25
      Caption = 'Dump EPROMs'
      TabOrder = 1
      OnClick = DumpEPROMSButton1Click
    end
    object BinaryButton1: TButton
      Left = 80
      Top = 3
      Width = 68
      Height = 25
      Caption = 'Binary CPM'
      TabOrder = 2
      OnClick = BinaryButton1Click
    end
    object HexCPMButton1: TButton
      Left = 7
      Top = 3
      Width = 70
      Height = 25
      Caption = 'Hex CPM'
      TabOrder = 3
      OnClick = HexCPMButton1Click
    end
    object ListButton1: TButton
      Left = 154
      Top = 3
      Width = 64
      Height = 25
      Caption = 'View List'
      TabOrder = 4
      OnClick = ListButton1Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 741
    Width = 527
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object Memo1: TMemo
    Left = 0
    Top = 32
    Width = 527
    Height = 709
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
