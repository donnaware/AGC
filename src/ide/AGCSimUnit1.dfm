object Form1: TForm1
  Left = 247
  Top = 110
  BorderStyle = bsSingle
  Caption = ' Apollo Automatic Guidance Computer Simulator'
  ClientHeight = 503
  ClientWidth = 673
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 123
    Top = 10
    Width = 0
    Height = 20
    Caption = 'Lamp Test'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Layout = blGlyphTop
    ParentFont = False
    OnMouseDown = LampTestButton1MouseDown
    OnMouseUp = LampTestButton1MouseUp
  end
  object Panel2: TPanel
    Left = 1
    Top = 329
    Width = 441
    Height = 170
    Color = clGray
    TabOrder = 0
    object DSKY_Button_VERB: TButton
      Tag = 47
      Left = 7
      Top = 38
      Width = 55
      Height = 47
      Caption = 'VERB'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_NOUN: TButton
      Tag = 42
      Left = 7
      Top = 94
      Width = 55
      Height = 47
      Caption = 'NOUN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_Plus: TButton
      Tag = 43
      Left = 69
      Top = 8
      Width = 55
      Height = 47
      Caption = '+'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_Minus: TButton
      Tag = 45
      Left = 69
      Top = 62
      Width = 55
      Height = 47
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_0: TButton
      Tag = 48
      Left = 69
      Top = 116
      Width = 55
      Height = 47
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_7: TButton
      Tag = 55
      Left = 131
      Top = 8
      Width = 55
      Height = 47
      Caption = '7'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_4: TButton
      Tag = 52
      Left = 131
      Top = 62
      Width = 55
      Height = 47
      Caption = '4'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_1: TButton
      Tag = 49
      Left = 131
      Top = 116
      Width = 55
      Height = 47
      Caption = '1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_8: TButton
      Tag = 56
      Left = 193
      Top = 8
      Width = 55
      Height = 47
      Caption = '8'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_5: TButton
      Tag = 53
      Left = 193
      Top = 62
      Width = 55
      Height = 47
      Caption = '5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_2: TButton
      Tag = 50
      Left = 193
      Top = 116
      Width = 55
      Height = 47
      Caption = '2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_9: TButton
      Tag = 57
      Left = 255
      Top = 8
      Width = 55
      Height = 47
      Caption = '9'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_6: TButton
      Tag = 54
      Left = 255
      Top = 62
      Width = 55
      Height = 47
      Caption = '6'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 12
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_3: TButton
      Tag = 51
      Left = 255
      Top = 116
      Width = 55
      Height = 47
      Caption = '3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 13
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_CLR: TButton
      Tag = 46
      Left = 317
      Top = 8
      Width = 55
      Height = 47
      Caption = 'CLR'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 14
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_PRO: TButton
      Tag = 112
      Left = 317
      Top = 62
      Width = 55
      Height = 47
      Caption = 'PRO'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 15
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_KREL: TButton
      Tag = 103
      Left = 317
      Top = 116
      Width = 55
      Height = 47
      Caption = 'K REL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 16
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_ENTR: TButton
      Tag = 106
      Left = 379
      Top = 38
      Width = 55
      Height = 47
      Caption = 'ENTR'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 17
      OnClick = DSKY_Button_0Click
    end
    object DSKY_Button_RSET: TButton
      Tag = 104
      Left = 379
      Top = 94
      Width = 55
      Height = 47
      Caption = 'RSET'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 18
      OnClick = DSKY_Button_0Click
    end
  end
  object Panel3: TPanel
    Left = 1
    Top = 3
    Width = 210
    Height = 322
    Color = clBlack
    TabOrder = 1
    object LAMP_UPLINKACTY: TPanel
      Left = 19
      Top = 6
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 0
      object Label2: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'UPLINK ACTY'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_TEMP: TPanel
      Left = 112
      Top = 6
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 1
      object Label3: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'TEMP'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_NOATT: TPanel
      Left = 19
      Top = 57
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 2
      object Label4: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'NO ATT'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_GIMBALLOCK: TPanel
      Left = 112
      Top = 57
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 3
      object Label5: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'GIMBAL LOCK'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_KEYREL: TPanel
      Left = 19
      Top = 108
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 4
      object Label6: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'KEY REL'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_RESTART: TPanel
      Left = 112
      Top = 108
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 5
      object Label7: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'RESTART'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_OPPERR: TPanel
      Left = 19
      Top = 159
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 6
      object Label8: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'OPP ERR'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_TRACKER: TPanel
      Left = 112
      Top = 159
      Width = 78
      Height = 46
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 7
      object Label9: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'TRACKER'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_BLANK1: TPanel
      Left = 19
      Top = 210
      Width = 78
      Height = 49
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 8
      object Label10: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_ALT: TPanel
      Left = 112
      Top = 210
      Width = 78
      Height = 49
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 9
      object Label11: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'ALT'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_BLANK2: TPanel
      Left = 19
      Top = 264
      Width = 78
      Height = 49
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 10
      object Label12: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object LAMP_VEL: TPanel
      Left = 112
      Top = 264
      Width = 78
      Height = 49
      BevelOuter = bvNone
      Color = clGray
      TabOrder = 11
      object Label13: TLabel
        Left = 4
        Top = 8
        Width = 69
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'VEL'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
  end
  object DisplayPanel: TPanel
    Left = 217
    Top = 2
    Width = 225
    Height = 323
    Color = clGray
    TabOrder = 2
    object Shape15: TShape
      Left = 6
      Top = 264
      Width = 214
      Height = 4
      Brush.Color = clTeal
      Pen.Style = psClear
    end
    object Shape71: TShape
      Left = 6
      Top = 207
      Width = 216
      Height = 4
      Brush.Color = clTeal
      Pen.Style = psClear
    end
    object Shape124: TShape
      Left = 6
      Top = 147
      Width = 215
      Height = 4
      Brush.Color = clTeal
      Pen.Style = psClear
    end
    object PaintBox2: TPaintBox
      Tag = 2
      Left = 142
      Top = 24
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox3: TPaintBox
      Tag = 1
      Left = 181
      Top = 24
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox4: TPaintBox
      Tag = 3
      Left = 25
      Top = 95
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox5: TPaintBox
      Tag = 4
      Left = 64
      Top = 95
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox6: TPaintBox
      Tag = 5
      Left = 141
      Top = 95
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox7: TPaintBox
      Tag = 6
      Left = 180
      Top = 95
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox8: TPaintBox
      Tag = 7
      Left = 25
      Top = 152
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox9: TPaintBox
      Tag = 8
      Left = 64
      Top = 152
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox10: TPaintBox
      Tag = 9
      Left = 103
      Top = 152
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox11: TPaintBox
      Tag = 10
      Left = 142
      Top = 152
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox12: TPaintBox
      Tag = 11
      Left = 181
      Top = 152
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox13: TPaintBox
      Tag = 12
      Left = 25
      Top = 212
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox14: TPaintBox
      Tag = 13
      Left = 64
      Top = 212
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox15: TPaintBox
      Tag = 14
      Left = 103
      Top = 212
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox16: TPaintBox
      Tag = 15
      Left = 142
      Top = 212
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox17: TPaintBox
      Tag = 16
      Left = 181
      Top = 212
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox18: TPaintBox
      Tag = 17
      Left = 25
      Top = 270
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox19: TPaintBox
      Tag = 18
      Left = 64
      Top = 270
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox20: TPaintBox
      Tag = 19
      Left = 103
      Top = 270
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox21: TPaintBox
      Tag = 20
      Left = 142
      Top = 270
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox22: TPaintBox
      Tag = 21
      Left = 181
      Top = 270
      Width = 40
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox1: TPaintBox
      Tag = 22
      Left = 6
      Top = 152
      Width = 20
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox23: TPaintBox
      Tag = 23
      Left = 6
      Top = 212
      Width = 20
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object PaintBox24: TPaintBox
      Tag = 24
      Left = 6
      Top = 270
      Width = 20
      Height = 50
      OnPaint = PaintBox1Paint
    end
    object StaticText1: TStaticText
      Left = 25
      Top = 80
      Width = 79
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'VERB'
      Color = clLime
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
    object StaticText2: TStaticText
      Left = 142
      Top = 80
      Width = 79
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'NOUN'
      Color = clLime
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      TabOrder = 1
    end
    object LAMP_COMPACTY: TPanel
      Left = 19
      Top = 11
      Width = 53
      Height = 49
      BevelOuter = bvNone
      Color = 13056
      TabOrder = 2
      object Label1: TLabel
        Left = 4
        Top = 10
        Width = 46
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'COMP ACTY'
        Color = clGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
    end
    object StaticText4: TStaticText
      Left = 142
      Top = 8
      Width = 79
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'PROG'
      Color = clLime
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      TabOrder = 3
    end
  end
  object Panel1: TPanel
    Left = 446
    Top = 2
    Width = 112
    Height = 497
    BevelOuter = bvLowered
    Color = clSilver
    TabOrder = 3
    object Label15: TLabel
      Left = 1
      Top = 1
      Width = 110
      Height = 16
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'MainCommands'
      Color = clGray
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object ExitButton1: TButton
      Left = 3
      Top = 470
      Width = 107
      Height = 24
      Caption = 'Exit Simulator'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = ExitButton1Click
    end
    object ShowMonitorButton1: TButton
      Left = 3
      Top = 326
      Width = 107
      Height = 24
      Caption = 'Hide Monitor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = ShowMonitorButton1Click
    end
    object RefreshDisplayButton1: TButton
      Left = 3
      Top = 352
      Width = 107
      Height = 24
      Caption = 'Refresh Display'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = RefreshDisplayButton1Click
    end
    object LoadMemoryButton1: TButton
      Left = 3
      Top = 274
      Width = 107
      Height = 24
      Caption = 'Load Object'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = LoadMemoryButton1Click
    end
    object ShowSourceButton1: TButton
      Left = 3
      Top = 48
      Width = 107
      Height = 24
      Caption = 'Show Source'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = ShowSourceButton1Click
    end
    object RunButton1: TButton
      Left = 3
      Top = 129
      Width = 107
      Height = 24
      Caption = 'Run'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = RunButton1Click
    end
    object PowerUpResetButton1: TButton
      Left = 3
      Top = 156
      Width = 107
      Height = 24
      Caption = 'Power Up Reset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = PowerUpResetButton1Click
    end
    object FastClockButton1: TButton
      Left = 3
      Top = 184
      Width = 107
      Height = 24
      Caption = 'Fast Clock'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = FastClockButton1Click
    end
    object LoadSourceButton1: TButton
      Left = 3
      Top = 21
      Width = 107
      Height = 24
      Caption = 'Load Source'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = LoadSourceButton1Click
    end
    object ShowDebuggerButton1: TButton
      Left = 3
      Top = 300
      Width = 107
      Height = 24
      Caption = 'Hide Debugger'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
      OnClick = ShowDebuggerButton1Click
    end
    object CompileButton1: TButton
      Left = 3
      Top = 75
      Width = 107
      Height = 24
      Caption = 'Compile'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      OnClick = CompileButton1Click
    end
    object AboutButton1: TButton
      Left = 3
      Top = 443
      Width = 107
      Height = 24
      Caption = 'About Simulator'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
      OnClick = AboutButton1Click
    end
    object HelpButton1: TButton
      Left = 3
      Top = 416
      Width = 107
      Height = 24
      Caption = 'Help Manual'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 12
      OnClick = HelpButton1Click
    end
    object LoadProgramButton1: TButton
      Left = 3
      Top = 102
      Width = 107
      Height = 24
      Caption = 'Load Program'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 13
      OnClick = LoadProgramButton1Click
    end
  end
  object DebuggerPanel1: TPanel
    Left = 560
    Top = 2
    Width = 112
    Height = 497
    Caption = 'DebuggerPanel1'
    Color = clSilver
    TabOrder = 4
    object LampTestButton1: TSpeedButton
      Left = 3
      Top = 21
      Width = 107
      Height = 24
      Caption = 'Lamp Test'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseDown = LampTestButton1MouseDown
      OnMouseUp = LampTestButton1MouseUp
    end
    object Label14: TLabel
      Left = 1
      Top = 1
      Width = 110
      Height = 16
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Debug Commands'
      Color = clGray
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object DecCntrButton1: TButton
      Left = 3
      Top = 296
      Width = 107
      Height = 24
      Caption = 'Decrment Cntr'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = DecCntrButton1Click
    end
    object IncrCntrButton1: TButton
      Left = 3
      Top = 268
      Width = 107
      Height = 24
      Caption = 'Incrment Cntr'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = IncrCntrButton1Click
    end
    object ToggleScalerButton1: TButton
      Left = 3
      Top = 240
      Width = 107
      Height = 24
      Caption = 'Toggle Scaler'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = ToggleScalerButton1Click
    end
    object InterruptButton1: TButton
      Left = 3
      Top = 212
      Width = 107
      Height = 24
      Caption = 'Interrupt'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = InterruptButton1Click
    end
    object ExamineMemoryButton1: TButton
      Left = 3
      Top = 184
      Width = 107
      Height = 24
      Caption = 'Examine Memory'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = ExamineMemoryButton1Click
    end
    object StandbyAllowedButton1: TButton
      Left = 3
      Top = 156
      Width = 107
      Height = 24
      Caption = 'Standby Allowed'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = StandbyAllowedButton1Click
    end
    object ClearAlarmsButton1: TButton
      Left = 3
      Top = 129
      Width = 107
      Height = 24
      Caption = 'Clear Alarms'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = ClearAlarmsButton1Click
    end
    object ToggleWatchButton1: TButton
      Left = 3
      Top = 102
      Width = 107
      Height = 24
      Caption = 'Toggle Watch'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = ToggleWatchButton1Click
    end
    object ToggleBreakpointButton1: TButton
      Left = 3
      Top = 75
      Width = 107
      Height = 24
      Caption = 'Toggle Break'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = ToggleBreakpointButton1Click
    end
    object InstructionButton1: TButton
      Left = 3
      Top = 48
      Width = 107
      Height = 24
      Caption = 'Instruction'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 9
      OnClick = InstructionButton1Click
    end
    object StepButton1: TButton
      Left = 3
      Top = 352
      Width = 107
      Height = 24
      Caption = 'Step'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      OnClick = StepButton1Click
    end
    object SingleClockButton1: TButton
      Left = 3
      Top = 324
      Width = 107
      Height = 24
      Caption = 'Single Clock'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
      OnClick = SingleClockButton1Click
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'obj'
    Filter = 'Object File (*.obj)|*.obj|All Files (*.*)|*.*'
    InitialDir = '.'
    Title = 'Load Memory File:'
    Left = 321
    Top = 16
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = '*.asm'
    Filter = 'Assembler File (*.asm)|*.asm|All Files (*.*)|*.*'
    InitialDir = '.'
    Title = 'Open Asm File...'
    Left = 290
    Top = 16
  end
end
