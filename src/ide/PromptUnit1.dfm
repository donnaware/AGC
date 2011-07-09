object PromptForm1: TPromptForm1
  Left = 246
  Top = 651
  Width = 467
  Height = 77
  Caption = ' Command Prompt'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 8
    Top = 10
    Width = 321
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 331
    Top = 9
    Width = 59
    Height = 22
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 395
    Top = 9
    Width = 59
    Height = 22
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
end
