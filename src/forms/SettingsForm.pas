unit SettingsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, TranslatorUnit, SettingUnit;

type
  TfrmSettings = class(TForm)
    pcSettings: TPageControl;
    tsGeneral: TTabSheet;
    tsAPI: TTabSheet;
    tsWindow: TTabSheet;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    
    // General settings
    lblApiProvider: TLabel;
    cmbApiProvider: TComboBox;
    lblTargetLanguage: TLabel;
    cmbTargetLanguage: TComboBox;
    chkContextAware: TCheckBox;
    lblSyncInterval: TLabel;
    edtSyncInterval: TEdit;
    udSyncInterval: TUpDown;
    
    // Window settings
    chkTopmost: TCheckBox;
    chkCaptionLog: TCheckBox;
    lblCaptionLogMax: TLabel;
    edtCaptionLogMax: TEdit;
    udCaptionLogMax: TUpDown;
    chkLatencyShow: TCheckBox;
    
    // Overlay settings
    gbOverlay: TGroupBox;
    lblFontSize: TLabel;
    edtFontSize: TEdit;
    udFontSize: TUpDown;
    lblOpacity: TLabel;
    tbOpacity: TTrackBar;
    lblOpacityValue: TLabel;
    
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure cmbApiProviderChange(Sender: TObject);
    procedure tbOpacityChange(Sender: TObject);
  private
    FSettings: TSettings;
    
    procedure LoadSettings;
    procedure SaveSettings;
    procedure UpdateLanguageList;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfrmSettings.btnApplyClick(Sender: TObject);
begin
  SaveSettings;
end;

procedure TfrmSettings.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmSettings.btnOKClick(Sender: TObject);
begin
  SaveSettings;
  ModalResult := mrOK;
end;

procedure TfrmSettings.cmbApiProviderChange(Sender: TObject);
begin
  UpdateLanguageList;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  FSettings := TTranslator.Setting;
  
  // Initialize API provider list
  cmbApiProvider.Items.Clear;
  cmbApiProvider.Items.Add('Google');
  cmbApiProvider.Items.Add('Google2');
  cmbApiProvider.Items.Add('Ollama');
  cmbApiProvider.Items.Add('OpenAI');
  cmbApiProvider.Items.Add('OpenRouter');
  cmbApiProvider.Items.Add('DeepL');
  cmbApiProvider.Items.Add('Youdao');
  cmbApiProvider.Items.Add('Baidu');
  cmbApiProvider.Items.Add('MTranServer');
  cmbApiProvider.Items.Add('LibreTranslate');
  
  LoadSettings;
  UpdateLanguageList;
end;

procedure TfrmSettings.LoadSettings;
begin
  if not Assigned(FSettings) then
    Exit;
    
  // General settings
  cmbApiProvider.Text := FSettings.ApiName;
  cmbTargetLanguage.Text := FSettings.TargetLanguage;
  chkContextAware.Checked := FSettings.ContextAware;
  edtSyncInterval.Text := IntToStr(FSettings.MaxSyncInterval);
  udSyncInterval.Position := FSettings.MaxSyncInterval;
  
  // Window settings
  if Assigned(FSettings.MainWindow) then
  begin
    chkTopmost.Checked := FSettings.MainWindow.Topmost;
    chkCaptionLog.Checked := FSettings.MainWindow.CaptionLogEnabled;
    edtCaptionLogMax.Text := IntToStr(FSettings.MainWindow.CaptionLogMax);
    udCaptionLogMax.Position := FSettings.MainWindow.CaptionLogMax;
    chkLatencyShow.Checked := FSettings.MainWindow.LatencyShow;
  end;
  
  // Overlay settings
  if Assigned(FSettings.OverlayWindow) then
  begin
    edtFontSize.Text := IntToStr(FSettings.OverlayWindow.FontSize);
    udFontSize.Position := FSettings.OverlayWindow.FontSize;
    tbOpacity.Position := FSettings.OverlayWindow.Opacity;
    lblOpacityValue.Caption := IntToStr(FSettings.OverlayWindow.Opacity);
  end;
end;

procedure TfrmSettings.SaveSettings;
begin
  if not Assigned(FSettings) then
    Exit;
    
  // General settings
  FSettings.ApiName := cmbApiProvider.Text;
  FSettings.TargetLanguage := cmbTargetLanguage.Text;
  FSettings.ContextAware := chkContextAware.Checked;
  FSettings.MaxSyncInterval := udSyncInterval.Position;
  
  // Window settings
  if Assigned(FSettings.MainWindow) then
  begin
    FSettings.MainWindow.Topmost := chkTopmost.Checked;
    FSettings.MainWindow.CaptionLogEnabled := chkCaptionLog.Checked;
    FSettings.MainWindow.CaptionLogMax := udCaptionLogMax.Position;
    FSettings.MainWindow.LatencyShow := chkLatencyShow.Checked;
  end;
  
  // Overlay settings
  if Assigned(FSettings.OverlayWindow) then
  begin
    FSettings.OverlayWindow.FontSize := udFontSize.Position;
    FSettings.OverlayWindow.Opacity := tbOpacity.Position;
  end;
  
  FSettings.Save;
end;

procedure TfrmSettings.tbOpacityChange(Sender: TObject);
begin
  lblOpacityValue.Caption := IntToStr(tbOpacity.Position);
end;

procedure TfrmSettings.UpdateLanguageList;
begin
  // Update language list based on selected API provider
  cmbTargetLanguage.Items.Clear;
  cmbTargetLanguage.Items.Add('zh-CN');
  cmbTargetLanguage.Items.Add('zh-TW');
  cmbTargetLanguage.Items.Add('en-US');
  cmbTargetLanguage.Items.Add('en-GB');
  cmbTargetLanguage.Items.Add('ja-JP');
  cmbTargetLanguage.Items.Add('ko-KR');
  cmbTargetLanguage.Items.Add('fr-FR');
  cmbTargetLanguage.Items.Add('th-TH');
end;

end.