object TabStopsForm1: TTabStopsForm1
  Left = 244
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Set Tab Stops'
  ClientHeight = 195
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object OKButton1: TButton
    Left = 11
    Top = 153
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKButton1Click
  end
  object CancelButton: TButton
    Left = 97
    Top = 153
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelButtonClick
  end
  object GroupBox1: TGroupBox
    Left = 11
    Top = 13
    Width = 291
    Height = 84
    Caption = ' Tab Distances: '
    TabOrder = 2
    object Label1: TLabel
      Left = 49
      Top = 22
      Width = 79
      Height = 13
      Caption = 'Number of Tabs:'
    end
    object Label2: TLabel
      Left = 57
      Top = 55
      Width = 72
      Height = 13
      Caption = 'Tab Distances:'
    end
    object TabEdit1: TEdit
      Left = 134
      Top = 51
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '4'
    end
    object TabUpDown1: TUpDown
      Left = 255
      Top = 51
      Width = 15
      Height = 21
      Associate = TabEdit1
      Min = 1
      Position = 4
      TabOrder = 1
      Wrap = False
    end
    object NumTabsEdit1: TEdit
      Left = 135
      Top = 17
      Width = 121
      Height = 21
      TabOrder = 2
      Text = '20'
    end
    object NumTabsUpDown1: TUpDown
      Left = 256
      Top = 17
      Width = 15
      Height = 21
      Associate = NumTabsEdit1
      Min = 0
      Position = 20
      TabOrder = 3
      Wrap = False
    end
  end
  object GroupBox2: TGroupBox
    Left = 11
    Top = 98
    Width = 292
    Height = 41
    Caption = ' Tabs to Spaces '
    TabOrder = 3
    object Label3: TLabel
      Left = 49
      Top = 19
      Width = 79
      Height = 13
      Caption = 'Spaces per Tab:'
    end
    object TabSpacesEdit1: TEdit
      Left = 135
      Top = 13
      Width = 122
      Height = 21
      TabOrder = 0
      Text = '4'
    end
    object TabSpacesUpDown1: TUpDown
      Left = 257
      Top = 13
      Width = 15
      Height = 21
      Associate = TabSpacesEdit1
      Min = 0
      Position = 4
      TabOrder = 1
      Wrap = False
    end
  end
end
