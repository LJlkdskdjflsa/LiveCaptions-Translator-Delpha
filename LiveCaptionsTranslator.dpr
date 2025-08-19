program LiveCaptionsTranslator;

uses
  Vcl.Forms,
  System.SysUtils,
  MainForm in 'src\forms\MainForm.pas' {frmMain},
  OverlayForm in 'src\forms\OverlayForm.pas' {frmOverlay},
  SettingsForm in 'src\forms\SettingsForm.pas' {frmSettings},
  WelcomeForm in 'src\forms\WelcomeForm.pas' {frmWelcome},
  CaptionUnit in 'src\models\CaptionUnit.pas',
  SettingUnit in 'src\models\SettingUnit.pas',
  TranslateAPIConfigUnit in 'src\models\TranslateAPIConfigUnit.pas',
  TranslationHistoryUnit in 'src\models\TranslationHistoryUnit.pas',
  WindowStateUnit in 'src\models\WindowStateUnit.pas',
  TranslatorUnit in 'src\core\TranslatorUnit.pas',
  LiveCaptionsHandlerUnit in 'src\utils\LiveCaptionsHandlerUnit.pas',
  TranslateAPIUnit in 'src\utils\TranslateAPIUnit.pas',
  WindowHandlerUnit in 'src\utils\WindowHandlerUnit.pas',
  WindowsAPIUnit in 'src\utils\WindowsAPIUnit.pas',
  HistoryLoggerUnit in 'src\utils\HistoryLoggerUnit.pas',
  TextUtilUnit in 'src\utils\TextUtilUnit.pas',
  UpdateUtilUnit in 'src\utils\UpdateUtilUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'LiveCaptions Translator';
  
  // Check if configuration exists, if not show welcome screen
  if not TSettings.IsConfigExist then
  begin
    Application.CreateForm(TfrmWelcome, frmWelcome);
    frmWelcome.ShowModal;
    frmWelcome.Free;
  end;
  
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmOverlay, frmOverlay);
  
  // Initialize translator
  TTranslator.Initialize;
  
  Application.Run;
end.