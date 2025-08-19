unit TranslateAPIConfigUnit;

interface

uses
  Classes, System.SysUtils, System.Generics.Collections, System.JSON, System.DateUtils;

type
  TTranslateAPIConfig = class
  private
    FOnPropertyChanged: TNotifyEvent;
  protected
    procedure DoPropertyChanged; virtual;
  public
    class function GetSupportedLanguages: TDictionary<string, string>; virtual;
    property OnPropertyChanged: TNotifyEvent read FOnPropertyChanged write FOnPropertyChanged;
  end;

  TMessage = class
  public
    Role: string;
    Content: string;
    constructor Create(const ARole, AContent: string);
  end;

  TBaseLLMConfig = class(TTranslateAPIConfig)
  private
    FModelName: string;
    FTemperature: Double;
    procedure SetModelName(const Value: string);
    procedure SetTemperature(const Value: Double);
  public
    constructor Create;
    property ModelName: string read FModelName write SetModelName;
    property Temperature: Double read FTemperature write SetTemperature;
  end;

  TOllamaResponse = class
  public
    Model: string;
    CreatedAt: TDateTime;
    Message: TMessage;
    Done: Boolean;
    TotalDuration: Int64;
    LoadDuration: Integer;
    PromptEvalCount: Integer;
    PromptEvalDuration: Int64;
    EvalCount: Integer;
    EvalDuration: Int64;
    destructor Destroy; override;
  end;

  TOllamaConfig = class(TBaseLLMConfig)
  private
    FPort: Integer;
    procedure SetPort(const Value: Integer);
  public
    constructor Create;
    property Port: Integer read FPort write SetPort;
  end;

  TChoice = class
  public
    Index: Integer;
    Message: TMessage;
    LogProbs: string;
    FinishReason: string;
    destructor Destroy; override;
  end;

  TUsage = class
  public
    PromptTokens: Integer;
    CompletionTokens: Integer;
    TotalTokens: Integer;
    PromptCacheHitTokens: Integer;
    PromptCacheMissTokens: Integer;
  end;

  TOpenAIResponse = class
  public
    Id: string;
    ObjectType: string;
    Created: Integer;
    Model: string;
    Choices: TObjectList<TChoice>;
    Usage: TUsage;
    SystemFingerprint: string;
    constructor Create;
    destructor Destroy; override;
  end;

  TOpenAIConfig = class(TBaseLLMConfig)
  private
    FApiKey: string;
    FApiUrl: string;
    procedure SetApiKey(const Value: string);
    procedure SetApiUrl(const Value: string);
  public
    constructor Create;
    property ApiKey: string read FApiKey write SetApiKey;
    property ApiUrl: string read FApiUrl write SetApiUrl;
  end;

  TOpenRouterConfig = class(TBaseLLMConfig)
  private
    FApiKey: string;
    procedure SetApiKey(const Value: string);
  public
    property ApiKey: string read FApiKey write SetApiKey;
  end;

  TDeepLConfig = class(TTranslateAPIConfig)
  private
    FApiKey: string;
    FApiUrl: string;
    procedure SetApiKey(const Value: string);
    procedure SetApiUrl(const Value: string);
  public
    constructor Create;
    class function GetSupportedLanguages: TDictionary<string, string>; override;
    property ApiKey: string read FApiKey write SetApiKey;
    property ApiUrl: string read FApiUrl write SetApiUrl;
  end;

  TYoudaoTranslationResult = class
  public
    ErrorCode: string;
    Query: string;
    Translation: TStringList;
    L: string;
    TSpeakUrl: string;
    SpeakUrl: string;
    constructor Create;
    destructor Destroy; override;
  end;

  TYoudaoConfig = class(TTranslateAPIConfig)
  private
    FAppKey: string;
    FAppSecret: string;
    FApiUrl: string;
    procedure SetAppKey(const Value: string);
    procedure SetAppSecret(const Value: string);
    procedure SetApiUrl(const Value: string);
  public
    constructor Create;
    class function GetSupportedLanguages: TDictionary<string, string>; override;
    property AppKey: string read FAppKey write SetAppKey;
    property AppSecret: string read FAppSecret write SetAppSecret;
    property ApiUrl: string read FApiUrl write SetApiUrl;
  end;

  TMTranServerResponse = class
  public
    Result: string;
  end;

  TMTranServerConfig = class(TTranslateAPIConfig)
  private
    FApiKey: string;
    FApiUrl: string;
    FSourceLanguage: string;
    procedure SetApiKey(const Value: string);
    procedure SetApiUrl(const Value: string);
    procedure SetSourceLanguage(const Value: string);
  public
    constructor Create;
    class function GetSupportedLanguages: TDictionary<string, string>; override;
    property ApiKey: string read FApiKey write SetApiKey;
    property ApiUrl: string read FApiUrl write SetApiUrl;
    property SourceLanguage: string read FSourceLanguage write SetSourceLanguage;
  end;

  TTransResult = class
  public
    Src: string;
    Dst: string;
  end;

  TBaiduTranslationResult = class
  public
    ErrorCode: string;
    From: string;
    ToLang: string;
    TransResult: TObjectList<TTransResult>;
    constructor Create;
    destructor Destroy; override;
  end;

  TBaiduConfig = class(TTranslateAPIConfig)
  private
    FAppId: string;
    FAppSecret: string;
    FApiUrl: string;
    procedure SetAppId(const Value: string);
    procedure SetAppSecret(const Value: string);
    procedure SetApiUrl(const Value: string);
  public
    constructor Create;
    class function GetSupportedLanguages: TDictionary<string, string>; override;
    property AppId: string read FAppId write SetAppId;
    property AppSecret: string read FAppSecret write SetAppSecret;
    property ApiUrl: string read FApiUrl write SetApiUrl;
  end;

  TLibreTranslateResponse = class
  public
    TranslatedText: string;
  end;

  TLibreTranslateConfig = class(TTranslateAPIConfig)
  private
    FApiKey: string;
    FApiUrl: string;
    procedure SetApiKey(const Value: string);
    procedure SetApiUrl(const Value: string);
  public
    constructor Create;
    class function GetSupportedLanguages: TDictionary<string, string>; override;
    property ApiKey: string read FApiKey write SetApiKey;
    property ApiUrl: string read FApiUrl write SetApiUrl;
  end;

implementation

uses
  TranslatorUnit;

{ TTranslateAPIConfig }

procedure TTranslateAPIConfig.DoPropertyChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged(Self);
    
  // Auto-save settings when properties change
  if Assigned(TTranslator.Setting) then
    TTranslator.Setting.Save;
end;

class function TTranslateAPIConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'zh-CN');
  Result.Add('zh-TW', 'zh-TW');
  Result.Add('en-US', 'en-US');
  Result.Add('en-GB', 'en-GB');
  Result.Add('ja-JP', 'ja-JP');
  Result.Add('ko-KR', 'ko-KR');
  Result.Add('fr-FR', 'fr-FR');
  Result.Add('th-TH', 'th-TH');
end;

{ TMessage }

constructor TMessage.Create(const ARole, AContent: string);
begin
  inherited Create;
  Role := ARole;
  Content := AContent;
end;

{ TBaseLLMConfig }

constructor TBaseLLMConfig.Create;
begin
  inherited;
  FModelName := '';
  FTemperature := 1.0;
end;

procedure TBaseLLMConfig.SetModelName(const Value: string);
begin
  if FModelName <> Value then
  begin
    FModelName := Value;
    DoPropertyChanged;
  end;
end;

procedure TBaseLLMConfig.SetTemperature(const Value: Double);
begin
  if FTemperature <> Value then
  begin
    FTemperature := Value;
    DoPropertyChanged;
  end;
end;

{ TOllamaConfig }

constructor TOllamaConfig.Create;
begin
  inherited;
  FPort := 11434;
end;

procedure TOllamaConfig.SetPort(const Value: Integer);
begin
  if FPort <> Value then
  begin
    FPort := Value;
    DoPropertyChanged;
  end;
end;

{ TOllamaResponse }

destructor TOllamaResponse.Destroy;
begin
  Message.Free;
  inherited;
end;

{ TOpenAIConfig }

constructor TOpenAIConfig.Create;
begin
  inherited;
  FApiKey := '';
  FApiUrl := '';
end;

procedure TOpenAIConfig.SetApiKey(const Value: string);
begin
  if FApiKey <> Value then
  begin
    FApiKey := Value;
    DoPropertyChanged;
  end;
end;

procedure TOpenAIConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

{ TChoice }

destructor TChoice.Destroy;
begin
  Message.Free;
  inherited;
end;

{ TOpenAIResponse }

constructor TOpenAIResponse.Create;
begin
  inherited;
  Choices := TObjectList<TChoice>.Create;
  Usage := TUsage.Create;
end;

destructor TOpenAIResponse.Destroy;
begin
  Choices.Free;
  Usage.Free;
  inherited;
end;

{ TOpenRouterConfig }

procedure TOpenRouterConfig.SetApiKey(const Value: string);
begin
  if FApiKey <> Value then
  begin
    FApiKey := Value;
    DoPropertyChanged;
  end;
end;

{ TDeepLConfig }

constructor TDeepLConfig.Create;
begin
  inherited;
  FApiKey := '';
  FApiUrl := 'https://api.deepl.com/v2/translate';
end;

class function TDeepLConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'ZH-HANS');
  Result.Add('zh-TW', 'ZH-HANT');
  Result.Add('en-US', 'EN-US');
  Result.Add('en-GB', 'EN-GB');
  Result.Add('ja-JP', 'JA');
  Result.Add('ko-KR', 'KO');
  Result.Add('fr-FR', 'FR');
  Result.Add('th-TH', 'TH');
end;

procedure TDeepLConfig.SetApiKey(const Value: string);
begin
  if FApiKey <> Value then
  begin
    FApiKey := Value;
    DoPropertyChanged;
  end;
end;

procedure TDeepLConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

{ TYoudaoConfig }

constructor TYoudaoConfig.Create;
begin
  inherited;
  FAppKey := '';
  FAppSecret := '';
  FApiUrl := 'https://openapi.youdao.com/api';
end;

class function TYoudaoConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'zh-CHS');
  Result.Add('zh-TW', 'zh-CHT');
  Result.Add('en-US', 'en');
  Result.Add('en-GB', 'en');
  Result.Add('ja-JP', 'ja');
  Result.Add('ko-KR', 'ko');
  Result.Add('fr-FR', 'fr');
  Result.Add('th-TH', 'th');
end;

procedure TYoudaoConfig.SetAppKey(const Value: string);
begin
  if FAppKey <> Value then
  begin
    FAppKey := Value;
    DoPropertyChanged;
  end;
end;

procedure TYoudaoConfig.SetAppSecret(const Value: string);
begin
  if FAppSecret <> Value then
  begin
    FAppSecret := Value;
    DoPropertyChanged;
  end;
end;

procedure TYoudaoConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

{ TYoudaoTranslationResult }

constructor TYoudaoTranslationResult.Create;
begin
  inherited;
  Translation := TStringList.Create;
end;

destructor TYoudaoTranslationResult.Destroy;
begin
  Translation.Free;
  inherited;
end;

{ TMTranServerConfig }

constructor TMTranServerConfig.Create;
begin
  inherited;
  FApiKey := '';
  FApiUrl := 'http://localhost:8989/translate';
  FSourceLanguage := 'en';
end;

class function TMTranServerConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'zh');
  Result.Add('zh-TW', 'zh');
  Result.Add('en-US', 'en');
  Result.Add('en-GB', 'en');
  Result.Add('ja-JP', 'ja');
  Result.Add('ko-KR', 'ko');
  Result.Add('fr-FR', 'fr');
  Result.Add('th-TH', 'th');
end;

procedure TMTranServerConfig.SetApiKey(const Value: string);
begin
  if FApiKey <> Value then
  begin
    FApiKey := Value;
    DoPropertyChanged;
  end;
end;

procedure TMTranServerConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

procedure TMTranServerConfig.SetSourceLanguage(const Value: string);
begin
  if FSourceLanguage <> Value then
  begin
    FSourceLanguage := Value;
    DoPropertyChanged;
  end;
end;

{ TBaiduConfig }

constructor TBaiduConfig.Create;
begin
  inherited;
  FAppId := '';
  FAppSecret := '';
  FApiUrl := 'https://fanyi-api.baidu.com/api/trans/vip/translate';
end;

class function TBaiduConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'zh');
  Result.Add('zh-TW', 'cht');
  Result.Add('en-US', 'en');
  Result.Add('en-GB', 'en');
  Result.Add('ja-JP', 'jp');
  Result.Add('ko-KR', 'kor');
  Result.Add('fr-FR', 'fra');
  Result.Add('th-TH', 'th');
end;

procedure TBaiduConfig.SetAppId(const Value: string);
begin
  if FAppId <> Value then
  begin
    FAppId := Value;
    DoPropertyChanged;
  end;
end;

procedure TBaiduConfig.SetAppSecret(const Value: string);
begin
  if FAppSecret <> Value then
  begin
    FAppSecret := Value;
    DoPropertyChanged;
  end;
end;

procedure TBaiduConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

{ TBaiduTranslationResult }

constructor TBaiduTranslationResult.Create;
begin
  inherited;
  TransResult := TObjectList<TTransResult>.Create;
end;

destructor TBaiduTranslationResult.Destroy;
begin
  TransResult.Free;
  inherited;
end;

{ TLibreTranslateConfig }

constructor TLibreTranslateConfig.Create;
begin
  inherited;
  FApiKey := '';
  FApiUrl := 'http://localhost:5000/translate';
end;

class function TLibreTranslateConfig.GetSupportedLanguages: TDictionary<string, string>;
begin
  Result := TDictionary<string, string>.Create;
  Result.Add('zh-CN', 'zh');
  Result.Add('zh-TW', 'zh');
  Result.Add('en-US', 'en');
  Result.Add('en-GB', 'en');
  Result.Add('ja-JP', 'ja');
  Result.Add('ko-KR', 'ko');
  Result.Add('fr-FR', 'fr');
  Result.Add('th-TH', 'th');
end;

procedure TLibreTranslateConfig.SetApiKey(const Value: string);
begin
  if FApiKey <> Value then
  begin
    FApiKey := Value;
    DoPropertyChanged;
  end;
end;

procedure TLibreTranslateConfig.SetApiUrl(const Value: string);
begin
  if FApiUrl <> Value then
  begin
    FApiUrl := Value;
    DoPropertyChanged;
  end;
end;

end.