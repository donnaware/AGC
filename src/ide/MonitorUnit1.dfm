object MonitorForm1: TMonitorForm1
  Left = 931
  Top = 109
  Width = 579
  Height = 531
  Caption = ' Monitor Display'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 371
    Width = 571
    Height = 15
    Align = alTop
    AutoSize = False
    Caption = ' Messages'
    Color = clGray
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 571
    Height = 371
    Align = alTop
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clLime
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      
        '----------------------------------------------------------------' +
        '----------------'
      
        '|  1      1          2        3         4         5         6   ' +
        '      7        |'
      
        '|  2      012345678901234567890123456789012345678901234567890123' +
        '456789012345678|'
      
        '|  3                                                            ' +
        '               |'
      
        '|  4                                                            ' +
        '               |'
      
        '|  5                                                            ' +
        '               |'
      
        '|  6                                                            ' +
        '               |'
      
        '|  7                                                            ' +
        '               |'
      
        '|  8                                                            ' +
        '               |'
      
        '|  9                                                            ' +
        '               |'
      
        '| 10                                                            ' +
        '               |'
      
        '| 11                                                            ' +
        '               |'
      
        '| 12                                                            ' +
        '               |'
      
        '| 13                                                            ' +
        '               |'
      
        '| 14                                                            ' +
        '               |'
      
        '| 15                                                            ' +
        '               |'
      
        '| 16                                                            ' +
        '               |'
      
        '| 17                                                            ' +
        '               |'
      
        '| 18                                                            ' +
        '               |'
      
        '| 19                                                            ' +
        '               |'
      
        '| 20                                                            ' +
        '               |'
      
        '| 21                                                            ' +
        '               |'
      
        '| 22                                                            ' +
        '               |'
      
        '| 23      012345678901234567890123456789012345678901234567890123' +
        '456789012345678|'
      
        '| 24      1          2        3         4         5         6   ' +
        '      7        |'
      
        '----------------------------------------------------------------' +
        '----------------'
      '')
    ParentFont = False
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 0
    Top = 386
    Width = 571
    Height = 118
    Align = alClient
    Color = clSilver
    Lines.Strings = (
      'Message Area')
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
