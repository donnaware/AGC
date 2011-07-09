object Form1: TForm1
  Left = 230
  Top = 115
  BorderStyle = bsDialog
  Caption = ' Console'
  ClientHeight = 330
  ClientWidth = 307
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ConWinCheckBox1: TCheckBox
    Left = 2
    Top = 202
    Width = 135
    Height = 17
    Caption = 'Show Console Window'
    TabOrder = 0
    OnClick = ConWinCheckBox1Click
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 32
    Width = 305
    Height = 169
    Caption = ' Input and Outputs '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object Label2: TLabel
      Left = 28
      Top = 29
      Width = 43
      Height = 16
      Caption = 'HEX 3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 93
      Top = 29
      Width = 43
      Height = 16
      Caption = 'HEX 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 157
      Top = 29
      Width = 43
      Height = 16
      Caption = 'HEX 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 221
      Top = 29
      Width = 43
      Height = 16
      Caption = 'HEX 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LED7: TShape
      Left = 24
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED6: TShape
      Left = 56
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED5: TShape
      Left = 88
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED4: TShape
      Left = 120
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED3: TShape
      Left = 152
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED2: TShape
      Left = 184
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED1: TShape
      Left = 216
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object LED0: TShape
      Left = 248
      Top = 104
      Width = 20
      Height = 20
      Brush.Color = 16384
      Pen.Color = clGreen
      Pen.Width = 2
      Shape = stCircle
    end
    object Label1: TLabel
      Left = 28
      Top = 128
      Width = 249
      Height = 13
      AutoSize = False
      Caption = 'S7    S6    S5     S4    S3    S2    S1    S0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object DIG_0: TComboBox
      Left = 217
      Top = 46
      Width = 48
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 0
      Text = '0'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        'A'
        'B'
        'C'
        'D'
        'E'
        'F')
    end
    object DIG_1: TComboBox
      Left = 153
      Top = 46
      Width = 48
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = '0'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        'A'
        'B'
        'C'
        'D'
        'E'
        'F')
    end
    object DIG_2: TComboBox
      Left = 91
      Top = 46
      Width = 48
      Height = 24
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 2
      Text = '0'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        'A'
        'B'
        'C'
        'D'
        'E'
        'F')
    end
    object DIG_3: TComboBox
      Left = 25
      Top = 46
      Width = 48
      Height = 24
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 3
      Text = '0'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        'A'
        'B'
        'C'
        'D'
        'E'
        'F')
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 311
    Width = 307
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Not Connected'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 307
    Height = 31
    Align = alTop
    BevelOuter = bvLowered
    Color = clSilver
    TabOrder = 3
    object SetValuesButton1: TButton
      Left = 120
      Top = 3
      Width = 130
      Height = 25
      Caption = 'Update Values Below'
      TabOrder = 0
      OnClick = SetValuesButton1Click
    end
    object ExitButton2: TButton
      Left = 263
      Top = 3
      Width = 40
      Height = 25
      Caption = 'Exit'
      TabOrder = 1
      OnClick = ExitButton2Click
    end
    object OpenButton1: TButton
      Left = 3
      Top = 3
      Width = 52
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = OpenButton1Click
    end
    object CloseButton1: TButton
      Left = 57
      Top = 3
      Width = 52
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = CloseButton1Click
    end
  end
  object TestPanel1: TPanel
    Left = 0
    Top = 222
    Width = 307
    Height = 89
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    Visible = False
    object Label6: TLabel
      Left = 2
      Top = 2
      Width = 303
      Height = 15
      Align = alTop
      AutoSize = False
      Caption = ' Test Area:'
      Color = clGray
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object SendStringButton1: TButton
      Left = 8
      Top = 26
      Width = 75
      Height = 23
      Caption = 'Send String'
      TabOrder = 0
      OnClick = SendStringButton1Click
    end
    object SendEdit1: TEdit
      Left = 88
      Top = 27
      Width = 201
      Height = 21
      TabOrder = 1
      Text = 'Test Text'
    end
    object ReadText1: TStaticText
      Left = 88
      Top = 58
      Width = 201
      Height = 20
      AutoSize = False
      BevelInner = bvLowered
      BevelKind = bkSoft
      Caption = 'Result'
      Color = clSilver
      ParentColor = False
      TabOrder = 2
    end
    object GetStringButton1: TButton
      Left = 8
      Top = 57
      Width = 75
      Height = 23
      Caption = 'Get String'
      TabOrder = 3
      OnClick = GetStringButton1Click
    end
  end
  object TestPanelCheckBox1: TCheckBox
    Left = 200
    Top = 202
    Width = 99
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Show test panel'
    TabOrder = 5
    OnClick = TestPanelCheckBox1Click
  end
end
