object WatchWin: TWatchWin
  Left = 822
  Top = 111
  Width = 778
  Height = 906
  BorderStyle = bsSizeToolWin
  Caption = 'Console Window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object WatchMemo: TMemo
    Left = 0
    Top = 0
    Width = 770
    Height = 879
    Hint = 'Watch Window'
    Align = alClient
    Color = clNavy
    Font.Charset = ANSI_CHARSET
    Font.Color = clYellow
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Watch Window')
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ReadOnly = True
    ScrollBars = ssBoth
    ShowHint = False
    TabOrder = 0
  end
  object PopupMenu1: TPopupMenu
    Left = 320
    Top = 16
    object ClearWatch: TMenuItem
      Caption = 'Clear'
      OnClick = ClearWatchClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
  end
end
