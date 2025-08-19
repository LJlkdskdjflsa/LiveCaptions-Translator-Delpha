object frmWelcome: TfrmWelcome
  Left = 0
  Top = 0
  Width = 450
  Height = 300
  BorderStyle = bsDialog
  Caption = 'Welcome to LiveCaptions Translator'
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 300
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object imgLogo: TImage
      Left = 175
      Top = 24
      Width = 100
      Height = 100
      Center = True
      Proportional = True
      Stretch = True
    end
    object lblTitle: TLabel
      Left = 0
      Top = 140
      Width = 450
      Height = 23
      Align = alTop
      Alignment = taCenter
      Caption = 'LiveCaptions Translator'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ExplicitWidth = 208
    end
    object lblDescription: TLabel
      Left = 0
      Top = 163
      Width = 450
      Height = 39
      Align = alTop
      Alignment = taCenter
      Caption = 
        'A real-time speech translation tool based on Windows LiveCaptio' +
        'ns.'#13#10'Configure your translation settings to get started.'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      WordWrap = True
      ExplicitWidth = 302
    end
    object lblVersion: TLabel
      Left = 0
      Top = 202
      Width = 450
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Version 1.0.0'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ExplicitWidth = 61
    end
    object btnGetStarted: TButton
      Left = 150
      Top = 230
      Width = 100
      Height = 30
      Caption = 'Get Started'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnGetStartedClick
    end
    object btnClose: TButton
      Left = 260
      Top = 230
      Width = 75
      Height = 30
      Cancel = True
      Caption = 'Close'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
end