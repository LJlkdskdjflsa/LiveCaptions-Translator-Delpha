object frmMain: TfrmMain
  Left = 0
  Top = 0
  Width = 750
  Height = 170
  BorderStyle = bsNone
  Caption = 'LiveCaptions Translator'
  Color = clWhite
  Constraints.MinHeight = 170
  Constraints.MinWidth = 750
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = pnlTopMouseDown
    object lblTitle: TLabel
      Left = 15
      Top = 6
      Width = 107
      Height = 13
      Caption = 'LiveCaptions Translator'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnClose: TSpeedButton
      Left = 725
      Top = 0
      Width = 25
      Height = 27
      Align = alRight
      Caption = #215
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = btnCloseClick
      ExplicitLeft = 700
    end
    object btnMinimize: TSpeedButton
      Left = 700
      Top = 0
      Width = 25
      Height = 27
      Align = alRight
      Caption = #8211
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = btnMinimizeClick
    end
    object btnTopmost: TSpeedButton
      Left = 645
      Top = 0
      Width = 25
      Height = 27
      Hint = 'Always on Top'
      AllowAllUp = True
      GroupIndex = 1
      Caption = #128204
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnTopmostClick
    end
    object btnOverlay: TSpeedButton
      Left = 620
      Top = 0
      Width = 25
      Height = 27
      Hint = 'Overlay Window'
      AllowAllUp = True
      GroupIndex = 2
      Caption = #128250
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnOverlayClick
    end
    object btnLogOnly: TSpeedButton
      Left = 595
      Top = 0
      Width = 25
      Height = 27
      Hint = 'Pause Translation (Log Only)'
      AllowAllUp = True
      GroupIndex = 3
      Caption = #9208
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnLogOnlyClick
    end
    object btnCaptionLog: TSpeedButton
      Left = 570
      Top = 0
      Width = 25
      Height = 27
      Hint = 'Log Cards of Captions'
      AllowAllUp = True
      GroupIndex = 4
      Caption = #128337
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
      OnClick = btnCaptionLogClick
    end
  end
  object pcMain: TPageControl
    Left = 0
    Top = 27
    Width = 750
    Height = 143
    ActivePage = tsCaption
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
    TabPosition = tpLeft
    TabWidth = 80
    OnChange = pcMainChange
    object tsCaption: TTabSheet
      Caption = 'Caption'
      ImageIndex = -1
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 665
        Height = 135
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object splCaptionLog: TSplitter
          Left = 0
          Top = 68
          Width = 665
          Height = 3
          Cursor = crVSplit
          Align = alTop
          Visible = False
          ExplicitTop = 46
          ExplicitWidth = 549
        end
        object pnlCaptionLog: TPanel
          Left = 0
          Top = 71
          Width = 665
          Height = 64
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object lvCaptionLog: TListView
            Left = 0
            Top = 0
            Width = 665
            Height = 64
            Align = alClient
            Columns = <
              item
                Caption = 'Time'
                Width = 100
              end
              item
                Caption = 'Original'
                Width = 250
              end
              item
                Caption = 'Translation'
                Width = 250
              end>
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object memoOriginal: TMemo
          Left = 0
          Top = 17
          Width = 665
          Height = 51
          Align = alTop
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
        end
        object lblOriginalCaption: TLabel
          Left = 0
          Top = 0
          Width = 665
          Height = 17
          Align = alTop
          Caption = 'Original Caption:'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          ExplicitWidth = 85
        end
        object memoTranslated: TMemo
          Left = 0
          Top = 68
          Width = 665
          Height = 67
          Align = alClient
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clWindow
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 2
        end
      end
    end
    object tsSettings: TTabSheet
      Caption = 'Settings'
      ImageIndex = 1
    end
    object tsHistory: TTabSheet
      Caption = 'History'
      ImageIndex = 2
    end
    object tsInfo: TTabSheet
      Caption = 'Info'
      ImageIndex = 3
    end
  end
  object imgIcons: TImageList
    Left = 24
    Top = 56
  end
end