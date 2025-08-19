object frmOverlay: TfrmOverlay
  Left = 0
  Top = 0
  Width = 650
  Height = 135
  BorderStyle = bsNone
  Caption = 'LiveCaptions Overlay'
  Color = clFuchsia
  TransparentColor = True
  TransparentColorValue = clFuchsia
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 135
    Align = alClient
    BevelOuter = bvNone
    Color = clGray
    ParentBackground = False
    TabOrder = 0
    object lblOriginal: TLabel
      Left = 10
      Top = 10
      Width = 630
      Height = 50
      AutoSize = False
      Caption = 'Original Caption'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lblTranslated: TLabel
      Left = 10
      Top = 70
      Width = 630
      Height = 50
      AutoSize = False
      Caption = 'Translated Caption'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
  end
end