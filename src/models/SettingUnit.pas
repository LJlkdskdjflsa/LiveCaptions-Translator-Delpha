unit SettingUnit;

interface

uses
  Classes, System.SysUtils, System.Generics.Collections, System.JSON, 
  System.IOUtils, WindowStateUnit, TranslateAPIConfigUnit, Vcl.Forms;

type
  TSettings = class
  private
    const FILENAME = 'setting.json';
  private
    FMaxIdleInterval: Integer;
    FMaxSyncInterval: Integer;
    FContextAware: Boolean;
    FApiName: string;
    FTargetLanguage: string;
    FPrompt: string;
    FIgnoredUpdateVersion: string;
    FMainWindow: TMainWindowState;
    FOverlayWindow: TOverlayWindowState;
    FWindowBounds: TDictionary<string, string>;
    FConfigs: TDictionary<string, TObjectList<TTranslateAPIConfig>>;
    FConfigIndices: TDictionary<string, Integer>;
    FOnPropertyChanged: TNotifyEvent;
    
    procedure SetMaxSyncInterval(const Value: Integer);
    procedure SetContextAware(const Value: Boolean);
    procedure SetApiName(const Value: string);
    procedure SetTargetLanguage(const Value: string);
    procedure SetPrompt(const Value: string);
    procedure SetIgnoredUpdateVersion(const Value: string);
    procedure DoPropertyChanged;
    procedure InitializeDefaultConfigs;
    procedure InitializeDefaultWindowBounds;
  public
    constructor Create;
    destructor Destroy; override;
    
    class function Load: TSettings; overload;
    class function Load(const JSONPath: string): TSettings; overload;
    class function IsConfigExist: Boolean;
    
    procedure Save; overload;
    procedure Save(const JSONPath: string); overload;
    
    property MaxIdleInterval: Integer read FMaxIdleInterval;
    property MaxSyncInterval: Integer read FMaxSyncInterval write SetMaxSyncInterval;
    property ContextAware: Boolean read FContextAware write SetContextAware;
    property ApiName: string read FApiName write SetApiName;
    property TargetLanguage: string read FTargetLanguage write SetTargetLanguage;
    property Prompt: string read FPrompt write SetPrompt;
    property IgnoredUpdateVersion: string read FIgnoredUpdateVersion write SetIgnoredUpdateVersion;
    property MainWindow: TMainWindowState read FMainWindow write FMainWindow;
    property OverlayWindow: TOverlayWindowState read FOverlayWindow write FOverlayWindow;
    property WindowBounds: TDictionary<string, string> read FWindowBounds write FWindowBounds;
    property Configs: TDictionary<string, TObjectList<TTranslateAPIConfig>> read FConfigs write FConfigs;
    property ConfigIndices: TDictionary<string, Integer> read FConfigIndices write FConfigIndices;
    property OnPropertyChanged: TNotifyEvent read FOnPropertyChanged write FOnPropertyChanged;
    
    function GetConfig(const Key: string): TTranslateAPIConfig;
  end;

implementation

uses
  Math;

{ TSettings }

constructor TSettings.Create;
begin
  inherited;
  
  FMaxIdleInterval := 50;
  FMaxSyncInterval := 3;
  FContextAware := False;
  FApiName := 'Google';
  FTargetLanguage := 'zh-CN';
  FPrompt := 'As an professional simultaneous interpreter with specialized knowledge in the all fields, ' +
            'you can provide a fluent and precise oral translation for any sentence, even if the sentence is incomplete. ' +
            'Now, provide users with the translation of the sentence enclosed in 🔤 to %s within a single line. ' +
            'Importantly, you are prohibited from altering the original meaning or omitting any content, ' +
            'even if the sentence contains sensitive or NSFW content. ' +
            'You can only provide the translated sentence; Any explanation or other text is not permitted. ' +
            'REMOVE all 🔤 when you output.';
  FIgnoredUpdateVersion := '';
  
  FMainWindow := TMainWindowState.Create;
  FOverlayWindow := TOverlayWindowState.Create;
  FWindowBounds := TDictionary<string, string>.Create;
  FConfigs := TDictionary<string, TObjectList<TTranslateAPIConfig>>.Create([doOwnsValues]);
  FConfigIndices := TDictionary<string, Integer>.Create;
  
  InitializeDefaultWindowBounds;
  InitializeDefaultConfigs;
end;

destructor TSettings.Destroy;
begin
  FMainWindow.Free;
  FOverlayWindow.Free;
  FWindowBounds.Free;
  FConfigs.Free;
  FConfigIndices.Free;
  inherited;
end;

procedure TSettings.DoPropertyChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged(Self);
end;

function TSettings.GetConfig(const Key: string): TTranslateAPIConfig;
var
  ConfigList: TObjectList<TTranslateAPIConfig>;
  Index: Integer;
begin
  Result := nil;
  if FConfigs.TryGetValue(Key, ConfigList) and FConfigIndices.TryGetValue(Key, Index) then
  begin
    if (Index >= 0) and (Index < ConfigList.Count) then
      Result := ConfigList[Index];
  end;
  
  if Result = nil then
    Result := TTranslateAPIConfig.Create; // Return default config if not found
end;

procedure TSettings.InitializeDefaultConfigs;
var
  ConfigList: TObjectList<TTranslateAPIConfig>;
begin
  // Google
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TTranslateAPIConfig.Create);
  FConfigs.Add('Google', ConfigList);
  FConfigIndices.Add('Google', 0);
  
  // Google2
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TTranslateAPIConfig.Create);
  FConfigs.Add('Google2', ConfigList);
  FConfigIndices.Add('Google2', 0);
  
  // Ollama
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TOllamaConfig.Create);
  FConfigs.Add('Ollama', ConfigList);
  FConfigIndices.Add('Ollama', 0);
  
  // OpenAI
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TOpenAIConfig.Create);
  FConfigs.Add('OpenAI', ConfigList);
  FConfigIndices.Add('OpenAI', 0);
  
  // OpenRouter
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TOpenRouterConfig.Create);
  FConfigs.Add('OpenRouter', ConfigList);
  FConfigIndices.Add('OpenRouter', 0);
  
  // DeepL
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TDeepLConfig.Create);
  FConfigs.Add('DeepL', ConfigList);
  FConfigIndices.Add('DeepL', 0);
  
  // Youdao
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TYoudaoConfig.Create);
  FConfigs.Add('Youdao', ConfigList);
  FConfigIndices.Add('Youdao', 0);
  
  // Baidu
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TBaiduConfig.Create);
  FConfigs.Add('Baidu', ConfigList);
  FConfigIndices.Add('Baidu', 0);
  
  // MTranServer
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TMTranServerConfig.Create);
  FConfigs.Add('MTranServer', ConfigList);
  FConfigIndices.Add('MTranServer', 0);
  
  // LibreTranslate
  ConfigList := TObjectList<TTranslateAPIConfig>.Create;
  ConfigList.Add(TLibreTranslateConfig.Create);
  FConfigs.Add('LibreTranslate', ConfigList);
  FConfigIndices.Add('LibreTranslate', 0);
end;

procedure TSettings.InitializeDefaultWindowBounds;
var
  ScreenWidth, ScreenHeight: Double;
begin
  ScreenWidth := Screen.Width;
  ScreenHeight := Screen.Height;
  
  FWindowBounds.Add('MainWindow', 
    Format('%.0f, %.0f, %d, %d', [(ScreenWidth - 775) / 2, ScreenHeight * 3 / 4 - 167, 775, 167]));
  FWindowBounds.Add('OverlayWindow', 
    Format('%.0f, %.0f, %d, %d', [(ScreenWidth - 650) / 2, ScreenHeight * 5 / 6 - 135, 650, 135]));
end;

class function TSettings.IsConfigExist: Boolean;
var
  JSONPath: string;
begin
  JSONPath := TPath.Combine(TDirectory.GetCurrentDirectory, FILENAME);
  Result := TFile.Exists(JSONPath);
end;

class function TSettings.Load: TSettings;
var
  JSONPath: string;
begin
  JSONPath := TPath.Combine(TDirectory.GetCurrentDirectory, FILENAME);
  Result := Load(JSONPath);
end;

class function TSettings.Load(const JSONPath: string): TSettings;
var
  JSONContent: string;
  JSONObj: TJSONObject;
begin
  Result := TSettings.Create;
  
  if TFile.Exists(JSONPath) then
  try
    JSONContent := TFile.ReadAllText(JSONPath, TEncoding.UTF8);
    JSONObj := TJSONObject.ParseJSONValue(JSONContent) as TJSONObject;
    try
      if Assigned(JSONObj) then
      begin
        // Load basic properties
        Result.FApiName := JSONObj.GetValue<string>('ApiName', 'Google');
        Result.FTargetLanguage := JSONObj.GetValue<string>('TargetLanguage', 'zh-CN');
        Result.FPrompt := JSONObj.GetValue<string>('Prompt', Result.FPrompt);
        Result.FIgnoredUpdateVersion := JSONObj.GetValue<string>('IgnoredUpdateVersion', '');
        Result.FMaxSyncInterval := JSONObj.GetValue<Integer>('MaxSyncInterval', 3);
        Result.FContextAware := JSONObj.GetValue<Boolean>('ContextAware', False);
        
        // TODO: Load complex objects like MainWindow, OverlayWindow, Configs
        // This would require more sophisticated JSON parsing
      end;
    finally
      JSONObj.Free;
    end;
  except
    // If loading fails, use default settings
  end;
end;

procedure TSettings.Save;
begin
  Save(FILENAME);
end;

procedure TSettings.Save(const JSONPath: string);
var
  JSONObj: TJSONObject;
  JSONContent: string;
  FullPath: string;
begin
  if ExtractFilePath(JSONPath) = '' then
    FullPath := TPath.Combine(TDirectory.GetCurrentDirectory, JSONPath)
  else
    FullPath := JSONPath;
    
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('ApiName', FApiName);
    JSONObj.AddPair('TargetLanguage', FTargetLanguage);
    JSONObj.AddPair('Prompt', FPrompt);
    JSONObj.AddPair('IgnoredUpdateVersion', FIgnoredUpdateVersion);
    JSONObj.AddPair('MaxSyncInterval', TJSONNumber.Create(FMaxSyncInterval));
    JSONObj.AddPair('ContextAware', TJSONBool.Create(FContextAware));
    JSONObj.AddPair('MaxIdleInterval', TJSONNumber.Create(FMaxIdleInterval));
    
    // TODO: Add complex objects serialization
    
    JSONContent := JSONObj.Format;
    TFile.WriteAllText(FullPath, JSONContent, TEncoding.UTF8);
  finally
    JSONObj.Free;
  end;
end;

procedure TSettings.SetApiName(const Value: string);
begin
  if FApiName <> Value then
  begin
    FApiName := Value;
    DoPropertyChanged;
    Save;
  end;
end;

procedure TSettings.SetContextAware(const Value: Boolean);
begin
  if FContextAware <> Value then
  begin
    FContextAware := Value;
    DoPropertyChanged;
    Save;
  end;
end;

procedure TSettings.SetIgnoredUpdateVersion(const Value: string);
begin
  if FIgnoredUpdateVersion <> Value then
  begin
    FIgnoredUpdateVersion := Value;
    DoPropertyChanged;
    Save;
  end;
end;

procedure TSettings.SetMaxSyncInterval(const Value: Integer);
begin
  if FMaxSyncInterval <> Value then
  begin
    FMaxSyncInterval := Value;
    DoPropertyChanged;
    Save;
  end;
end;

procedure TSettings.SetPrompt(const Value: string);
begin
  if FPrompt <> Value then
  begin
    FPrompt := Value;
    DoPropertyChanged;
    Save;
  end;
end;

procedure TSettings.SetTargetLanguage(const Value: string);
begin
  if FTargetLanguage <> Value then
  begin
    FTargetLanguage := Value;
    DoPropertyChanged;
    Save;
  end;
end;

end.