object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  Width = 500
  Height = 400
  BorderStyle = bsDialog
  Caption = 'Settings - LiveCaptions Translator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcSettings: TPageControl
    Left = 8
    Top = 8
    Width = 484
    Height = 345
    ActivePage = tsGeneral
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = 'General'
      object lblApiProvider: TLabel
        Left = 16
        Top = 16
        Width = 68
        Height = 13
        Caption = 'API Provider:'
      end
      object lblTargetLanguage: TLabel
        Left = 16
        Top = 56
        Width = 83
        Height = 13
        Caption = 'Target Language:'
      end
      object lblSyncInterval: TLabel
        Left = 16
        Top = 136
        Width = 112
        Height = 13
        Caption = 'Max Sync Interval (s):'
      end
      object cmbApiProvider: TComboBox
        Left = 120
        Top = 13
        Width = 200
        Height = 21
        Style = csDropDownList
        TabOrder = 0
        OnChange = cmbApiProviderChange
      end
      object cmbTargetLanguage: TComboBox
        Left = 120
        Top = 53
        Width = 200
        Height = 21
        Style = csDropDownList
        TabOrder = 1
      end
      object chkContextAware: TCheckBox
        Left = 16
        Top = 96
        Width = 200
        Height = 17
        Caption = 'Context-aware translation'
        TabOrder = 2
      end
      object edtSyncInterval: TEdit
        Left = 150
        Top = 133
        Width = 50
        Height = 21
        TabOrder = 3
        Text = '3'
      end
      object udSyncInterval: TUpDown
        Left = 200
        Top = 133
        Width = 16
        Height = 21
        Associate = edtSyncInterval
        Min = 1
        Max = 10
        Position = 3
        TabOrder = 4
      end
    end
    object tsAPI: TTabSheet
      Caption = 'API Settings'
      ImageIndex = 1
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 280
        Height = 13
        Caption = 'API-specific settings will be displayed here based on selection'
      end
    end
    object tsWindow: TTabSheet
      Caption = 'Window'
      ImageIndex = 2
      object lblCaptionLogMax: TLabel
        Left = 16
        Top = 56
        Width = 104
        Height = 13
        Caption = 'Caption Log Max:'
      end
      object chkTopmost: TCheckBox
        Left = 16
        Top = 16
        Width = 150
        Height = 17
        Caption = 'Always on top'
        TabOrder = 0
      end
      object chkCaptionLog: TCheckBox
        Left = 16
        Top = 96
        Width = 150
        Height = 17
        Caption = 'Enable caption log'
        TabOrder = 1
      end
      object edtCaptionLogMax: TEdit
        Left = 150
        Top = 53
        Width = 50
        Height = 21
        TabOrder = 2
        Text = '2'
      end
      object udCaptionLogMax: TUpDown
        Left = 200
        Top = 53
        Width = 16
        Height = 21
        Associate = edtCaptionLogMax
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 3
      end
      object chkLatencyShow: TCheckBox
        Left = 16
        Top = 136
        Width = 150
        Height = 17
        Caption = 'Show latency'
        TabOrder = 4
      end
      object gbOverlay: TGroupBox
        Left = 250
        Top = 16
        Width = 200
        Height = 200
        Caption = 'Overlay Window'
        TabOrder = 5
        object lblFontSize: TLabel
          Left = 16
          Top = 24
          Width = 50
          Height = 13
          Caption = 'Font Size:'
        end
        object lblOpacity: TLabel
          Left = 16
          Top = 80
          Width = 42
          Height = 13
          Caption = 'Opacity:'
        end
        object lblOpacityValue: TLabel
          Left = 150
          Top = 104
          Width = 18
          Height = 13
          Caption = '150'
        end
        object edtFontSize: TEdit
          Left = 80
          Top = 21
          Width = 50
          Height = 21
          TabOrder = 0
          Text = '15'
        end
        object udFontSize: TUpDown
          Left = 130
          Top = 21
          Width = 16
          Height = 21
          Associate = edtFontSize
          Min = 8
          Max = 48
          Position = 15
          TabOrder = 1
        end
        object tbOpacity: TTrackBar
          Left = 16
          Top = 104
          Width = 130
          Height = 25
          Max = 255
          Min = 50
          Position = 150
          TabOrder = 2
          OnChange = tbOpacityChange
        end
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 360
    Width = 500
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 256
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 337
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnApply: TButton
      Left = 418
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = btnApplyClick
    end
  end
end