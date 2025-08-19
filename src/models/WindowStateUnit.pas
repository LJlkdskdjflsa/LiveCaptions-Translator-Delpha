unit WindowStateUnit;

interface

uses
  Classes, System.SysUtils;

type
  TWindowStateBase = class
  private
    FOnPropertyChanged: TNotifyEvent;
  protected
    procedure DoPropertyChanged; virtual;
  public
    property OnPropertyChanged: TNotifyEvent read FOnPropertyChanged write FOnPropertyChanged;
  end;

  TMainWindowState = class(TWindowStateBase)
  private
    FTopmost: Boolean;
    FCaptionLogEnabled: Boolean;
    FCaptionLogMax: Integer;
    FLatencyShow: Boolean;
    
    procedure SetTopmost(const Value: Boolean);
    procedure SetCaptionLogEnabled(const Value: Boolean);
    procedure SetCaptionLogMax(const Value: Integer);
    procedure SetLatencyShow(const Value: Boolean);
  public
    constructor Create;
    
    property Topmost: Boolean read FTopmost write SetTopmost;
    property CaptionLogEnabled: Boolean read FCaptionLogEnabled write SetCaptionLogEnabled;
    property CaptionLogMax: Integer read FCaptionLogMax write SetCaptionLogMax;
    property LatencyShow: Boolean read FLatencyShow write SetLatencyShow;
  end;

  TOverlayWindowState = class(TWindowStateBase)
  private
    FFontSize: Integer;
    FFontColor: Integer;
    FFontBold: Integer;
    FFontShadow: Integer;
    FBackgroundColor: Integer;
    FOpacity: Byte;
    FHistoryMax: Integer;
    
    procedure SetFontSize(const Value: Integer);
    procedure SetFontColor(const Value: Integer);
    procedure SetFontBold(const Value: Integer);
    procedure SetFontShadow(const Value: Integer);
    procedure SetBackgroundColor(const Value: Integer);
    procedure SetOpacity(const Value: Byte);
    procedure SetHistoryMax(const Value: Integer);
  public
    constructor Create;
    
    property FontSize: Integer read FFontSize write SetFontSize;
    property FontColor: Integer read FFontColor write SetFontColor;
    property FontBold: Integer read FFontBold write SetFontBold;
    property FontShadow: Integer read FFontShadow write SetFontShadow;
    property BackgroundColor: Integer read FBackgroundColor write SetBackgroundColor;
    property Opacity: Byte read FOpacity write SetOpacity;
    property HistoryMax: Integer read FHistoryMax write SetHistoryMax;
  end;

implementation

uses
  TranslatorUnit;

{ TWindowStateBase }

procedure TWindowStateBase.DoPropertyChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged(Self);
    
  // Auto-save settings when properties change
  if Assigned(TTranslator.Setting) then
    TTranslator.Setting.Save;
end;

{ TMainWindowState }

constructor TMainWindowState.Create;
begin
  inherited;
  FTopmost := True;
  FCaptionLogEnabled := False;
  FCaptionLogMax := 2;
  FLatencyShow := False;
end;

procedure TMainWindowState.SetCaptionLogEnabled(const Value: Boolean);
begin
  if FCaptionLogEnabled <> Value then
  begin
    FCaptionLogEnabled := Value;
    DoPropertyChanged;
  end;
end;

procedure TMainWindowState.SetCaptionLogMax(const Value: Integer);
begin
  if FCaptionLogMax <> Value then
  begin
    FCaptionLogMax := Value;
    DoPropertyChanged;
  end;
end;

procedure TMainWindowState.SetLatencyShow(const Value: Boolean);
begin
  if FLatencyShow <> Value then
  begin
    FLatencyShow := Value;
    DoPropertyChanged;
  end;
end;

procedure TMainWindowState.SetTopmost(const Value: Boolean);
begin
  if FTopmost <> Value then
  begin
    FTopmost := Value;
    DoPropertyChanged;
  end;
end;

{ TOverlayWindowState }

constructor TOverlayWindowState.Create;
begin
  inherited;
  FFontSize := 15;
  FFontColor := 1;
  FFontBold := 1;
  FFontShadow := 1;
  FBackgroundColor := 8;
  FOpacity := 150;
  FHistoryMax := 1;
end;

procedure TOverlayWindowState.SetBackgroundColor(const Value: Integer);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetFontBold(const Value: Integer);
begin
  if FFontBold <> Value then
  begin
    FFontBold := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetFontColor(const Value: Integer);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetFontShadow(const Value: Integer);
begin
  if FFontShadow <> Value then
  begin
    FFontShadow := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetFontSize(const Value: Integer);
begin
  if FFontSize <> Value then
  begin
    FFontSize := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetHistoryMax(const Value: Integer);
begin
  if FHistoryMax <> Value then
  begin
    FHistoryMax := Value;
    DoPropertyChanged;
  end;
end;

procedure TOverlayWindowState.SetOpacity(const Value: Byte);
begin
  if FOpacity <> Value then
  begin
    FOpacity := Value;
    DoPropertyChanged;
  end;
end;

end.