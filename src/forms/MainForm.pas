unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus, System.ImageList, Vcl.ImgList,
  TranslatorUnit, SettingUnit, WindowHandlerUnit, OverlayForm, SettingsForm,
  WelcomeForm, UpdateUtilUnit, LiveCaptionsHandlerUnit;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    pnlContent: TPanel;
    lblTitle: TLabel;
    btnTopmost: TSpeedButton;
    btnOverlay: TSpeedButton;
    btnLogOnly: TSpeedButton;
    btnCaptionLog: TSpeedButton;
    btnClose: TSpeedButton;
    btnMinimize: TSpeedButton;
    pcMain: TPageControl;
    tsCaption: TTabSheet;
    tsSettings: TTabSheet;
    tsHistory: TTabSheet;
    tsInfo: TTabSheet;
    imgIcons: TImageList;
    pnlCaption: TPanel;
    lblOriginalCaption: TLabel;
    lblTranslatedCaption: TLabel;
    memoOriginal: TMemo;
    memoTranslated: TMemo;
    pnlCaptionLog: TPanel;
    lvCaptionLog: TListView;
    splCaptionLog: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnTopmostClick(Sender: TObject);
    procedure btnOverlayClick(Sender: TObject);
    procedure btnLogOnlyClick(Sender: TObject);
    procedure btnCaptionLogClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WMMove(var Message: TMessage); message WM_MOVE;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FOverlayWindow: TfrmOverlay;
    FIsAutoHeight: Boolean;
    FSettings: TSettings;
    FTranslator: TTranslator;
    
    procedure InitializeUI;
    procedure LoadSettings;
    procedure SaveWindowState;
    procedure UpdateTopmostButton;
    procedure UpdateOverlayButton;
    procedure UpdateLogOnlyButton;
    procedure UpdateCaptionLogButton;
    procedure CheckForFirstUse;
    procedure CheckForUpdates;
    procedure ShowLogCard(Enabled: Boolean);
    procedure AutoHeightAdjust(MinHeight: Integer = -1; MaxHeight: Integer = -1);
    procedure OnCaptionChanged(Sender: TObject);
  public
    property OverlayWindow: TfrmOverlay read FOverlayWindow write FOverlayWindow;
    property IsAutoHeight: Boolean read FIsAutoHeight write FIsAutoHeight;
    
    procedure ToggleTopmost(Enabled: Boolean);
    procedure ShowSnackbar(const Title, Message: string; IsError: Boolean = False);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Math, CaptionUnit, ShellAPI;

procedure TfrmMain.AutoHeightAdjust(MinHeight, MaxHeight: Integer);
begin
  if (MinHeight > 0) and (Height < MinHeight) then
  begin
    Height := MinHeight;
    FIsAutoHeight := True;
  end;
  
  if FIsAutoHeight and (MaxHeight > 0) and (Height > MaxHeight) then
    Height := MaxHeight;
end;

procedure TfrmMain.btnCaptionLogClick(Sender: TObject);
begin
  if Assigned(FSettings) and Assigned(FSettings.MainWindow) then
  begin
    FSettings.MainWindow.CaptionLogEnabled := not FSettings.MainWindow.CaptionLogEnabled;
    ShowLogCard(FSettings.MainWindow.CaptionLogEnabled);
  end;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnLogOnlyClick(Sender: TObject);
begin
  if Assigned(FTranslator) then
  begin
    FTranslator.LogOnlyFlag := not FTranslator.LogOnlyFlag;
    UpdateLogOnlyButton;
  end;
end;

procedure TfrmMain.btnMinimizeClick(Sender: TObject);
begin
  WindowState := wsMinimized;
end;

procedure TfrmMain.btnOverlayClick(Sender: TObject);
begin
  if FOverlayWindow = nil then
  begin
    FOverlayWindow := TfrmOverlay.Create(Self);
    FOverlayWindow.Show;
  end
  else
  begin
    FreeAndNil(FOverlayWindow);
  end;
  UpdateOverlayButton;
end;

procedure TfrmMain.btnTopmostClick(Sender: TObject);
begin
  ToggleTopmost(not (FormStyle = fsStayOnTop));
end;

procedure TfrmMain.CheckForFirstUse;
begin
  if Assigned(FTranslator) and FTranslator.FirstUseFlag then
  begin
    pcMain.ActivePage := tsSettings;
    
    if Assigned(FTranslator.Window) then
      TLiveCaptionsHandler.RestoreLiveCaptions(FTranslator.Window);
      
    // Show welcome window
    with TfrmWelcome.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TfrmMain.CheckForUpdates;
begin
  // TODO: Implement update checking
  // This would require porting the UpdateUtil functionality
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveWindowState;
  if Assigned(FOverlayWindow) then
    FreeAndNil(FOverlayWindow);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FIsAutoHeight := True;
  FSettings := TTranslator.Setting;
  FTranslator := TTranslator.GetInstance;
  
  InitializeUI;
  LoadSettings;
  
  // Set up caption change notification
  if Assigned(TCaption.GetInstance) then
    TCaption.GetInstance.OnPropertyChanged := OnCaptionChanged;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FOverlayWindow) then
    FOverlayWindow.Free;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  FIsAutoHeight := False;
  SaveWindowState;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  CheckForFirstUse;
  CheckForUpdates;
end;

procedure TfrmMain.InitializeUI;
begin
  // Set up the form properties
  Caption := 'LiveCaptions Translator';
  BorderStyle := bsNone;
  Color := clWhite;
  Position := poDesigned;
  
  // Set up the top panel for dragging
  pnlTop.Height := 27;
  pnlTop.Align := alTop;
  pnlTop.Color := clBtnFace;
  pnlTop.BevelOuter := bvNone;
  
  // Set up page control
  pcMain.Align := alClient;
  pcMain.TabPosition := tpLeft;
  pcMain.ActivePage := tsCaption;
  
  // Initialize button states
  UpdateTopmostButton;
  UpdateOverlayButton;
  UpdateLogOnlyButton;
  UpdateCaptionLogButton;
end;

procedure TfrmMain.LoadSettings;
var
  WindowState: string;
  Bounds: TStringList;
begin
  if Assigned(FSettings) and FSettings.WindowBounds.ContainsKey('MainWindow') then
  begin
    WindowState := FSettings.WindowBounds['MainWindow'];
    Bounds := TStringList.Create;
    try
      Bounds.CommaText := WindowState;
      if Bounds.Count >= 4 then
      begin
        Left := StrToIntDef(Bounds[0], Left);
        Top := StrToIntDef(Bounds[1], Top);
        Width := StrToIntDef(Bounds[2], Width);
        Height := StrToIntDef(Bounds[3], Height);
      end;
    finally
      Bounds.Free;
    end;
  end;
  
  if Assigned(FSettings) and Assigned(FSettings.MainWindow) then
  begin
    ToggleTopmost(FSettings.MainWindow.Topmost);
    ShowLogCard(FSettings.MainWindow.CaptionLogEnabled);
  end;
end;

procedure TfrmMain.OnCaptionChanged(Sender: TObject);
var
  Caption: TCaption;
begin
  Caption := TCaption.GetInstance;
  if Assigned(Caption) then
  begin
    memoOriginal.Text := Caption.DisplayOriginalCaption;
    memoTranslated.Text := Caption.DisplayTranslatedCaption;
  end;
end;

procedure TfrmMain.pcMainChange(Sender: TObject);
begin
  // Handle page control tab changes
  case pcMain.ActivePageIndex of
    0: ; // Caption page
    1: ; // Settings page - could show settings form
    2: ; // History page
    3: ; // Info page
  end;
end;

procedure TfrmMain.pnlTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
  end;
end;

procedure TfrmMain.SaveWindowState;
var
  WindowState: string;
begin
  if Assigned(FSettings) then
  begin
    WindowState := Format('%d, %d, %d, %d', [Left, Top, Width, Height]);
    FSettings.WindowBounds.AddOrSetValue('MainWindow', WindowState);
    FSettings.Save;
  end;
end;

procedure TfrmMain.ShowLogCard(Enabled: Boolean);
begin
  pnlCaptionLog.Visible := Enabled;
  splCaptionLog.Visible := Enabled;
  UpdateCaptionLogButton;
end;

procedure TfrmMain.ShowSnackbar(const Title, Message: string; IsError: Boolean);
begin
  // Simple message box implementation - could be enhanced with a custom snackbar
  if IsError then
    MessageDlg(Title + #13#10 + Message, mtError, [mbOK], 0)
  else
    MessageDlg(Title + #13#10 + Message, mtInformation, [mbOK], 0);
end;

procedure TfrmMain.ToggleTopmost(Enabled: Boolean);
begin
  if Enabled then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
    
  if Assigned(FSettings) and Assigned(FSettings.MainWindow) then
    FSettings.MainWindow.Topmost := Enabled;
    
  UpdateTopmostButton;
end;

procedure TfrmMain.UpdateCaptionLogButton;
begin
  if Assigned(FSettings) and Assigned(FSettings.MainWindow) then
    btnCaptionLog.Down := FSettings.MainWindow.CaptionLogEnabled;
end;

procedure TfrmMain.UpdateLogOnlyButton;
begin
  if Assigned(FTranslator) then
    btnLogOnly.Down := FTranslator.LogOnlyFlag;
end;

procedure TfrmMain.UpdateOverlayButton;
begin
  btnOverlay.Down := Assigned(FOverlayWindow);
end;

procedure TfrmMain.UpdateTopmostButton;
begin
  btnTopmost.Down := (FormStyle = fsStayOnTop);
end;

procedure TfrmMain.WMMove(var Message: TMessage);
begin
  inherited;
  SaveWindowState;
end;

procedure TfrmMain.WMSize(var Message: TMessage);
begin
  inherited;
  SaveWindowState;
end;

end.