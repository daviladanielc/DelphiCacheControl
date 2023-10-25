object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Delphi Cache Control - Sample'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Button1: TButton
    Left = 112
    Top = 56
    Width = 113
    Height = 25
    Caption = 'Add Object'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 104
    Width = 113
    Height = 25
    Caption = 'Exists on Cache'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 112
    Top = 152
    Width = 113
    Height = 25
    Caption = 'Delete Item'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 112
    Top = 192
    Width = 113
    Height = 25
    Caption = 'Threads Test'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 280
    Top = 64
    Width = 297
    Height = 193
    ScrollBars = ssVertical
    TabOrder = 4
  end
end
