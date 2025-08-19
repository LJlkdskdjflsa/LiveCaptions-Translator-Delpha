unit TranslateAPIUnit;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.JSON, TranslateAPIConfigUnit, SettingUnit;

type
  TTranslateAPI = class
  private
    class var FIsLLMBased: Boolean;
    class var FCurrentConfig: TTranslateAPIConfig;
    
    class function TranslateGoogle(const Text: string): string;
    class function TranslateDeepL(const Text: string): string;
    class function TranslateOllama(const Text: string): string;
    class function TranslateOpenAI(const Text: string): string;
    class function TranslateYoudao(const Text: string): string;
    class function TranslateBaidu(const Text: string): string;
  public
    class property IsLLMBased: Boolean read FIsLLMBased;
    
    class function TranslateFunction(const Text: string): string;
    class procedure SetAPIProvider(const Provider: string; Config: TTranslateAPIConfig);
  end;

implementation

uses
  TranslatorUnit, System.NetEncoding, System.Hash;

{ TTranslateAPI }

class procedure TTranslateAPI.SetAPIProvider(const Provider: string; Config: TTranslateAPIConfig);
begin
  FCurrentConfig := Config;
  
  // Determine if the API is LLM-based
  FIsLLMBased := (Provider = 'Ollama') or (Provider = 'OpenAI') or (Provider = 'OpenRouter');
end;

class function TTranslateAPI.TranslateBaidu(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  PostData: TStringStream;
  JSONResponse: TJSONObject;
  Config: TBaiduConfig;
  Salt, Sign, PostContent: string;
begin
  Result := '[ERROR] Translation failed';
  
  if not (FCurrentConfig is TBaiduConfig) then
    Exit;
    
  Config := FCurrentConfig as TBaiduConfig;
  if (Config.AppId = '') or (Config.AppSecret = '') then
    Exit;
  
  HttpClient := THttpClient.Create;
  PostData := TStringStream.Create('', TEncoding.UTF8);
  try
    // Generate salt and sign for Baidu API
    Salt := IntToStr(Random(10000) + 1000);
    Sign := THashMD5.GetHashString(Config.AppId + Text + Salt + Config.AppSecret);
    
    PostContent := Format('q=%s&from=auto&to=%s&appid=%s&salt=%s&sign=%s',
      [TNetEncoding.URL.Encode(Text),
       TNetEncoding.URL.Encode('zh'), // Simplified - should use language mapping
       Config.AppId,
       Salt,
       Sign]);
    
    PostData.WriteString(PostContent);
    PostData.Position := 0;
    
    HttpClient.ContentType := 'application/x-www-form-urlencoded';
    Response := HttpClient.Post(Config.ApiUrl, PostData);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if Assigned(JSONResponse) then
        begin
          // Parse Baidu translation response
          // This is simplified - full implementation would handle the array structure
          Result := JSONResponse.GetValue<string>('trans_result[0].dst', '[ERROR] Invalid response');
        end;
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HttpClient.Free;
    PostData.Free;
  end;
end;

class function TTranslateAPI.TranslateDeepL(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  PostData: TStringStream;
  JSONResponse: TJSONObject;
  Config: TDeepLConfig;
  PostContent: string;
begin
  Result := '[ERROR] Translation failed';
  
  if not (FCurrentConfig is TDeepLConfig) then
    Exit;
    
  Config := FCurrentConfig as TDeepLConfig;
  if Config.ApiKey = '' then
    Exit;
  
  HttpClient := THttpClient.Create;
  PostData := TStringStream.Create('', TEncoding.UTF8);
  try
    PostContent := Format('text=%s&target_lang=%s&auth_key=%s',
      [TNetEncoding.URL.Encode(Text),
       TNetEncoding.URL.Encode('ZH'), // Simplified language code
       Config.ApiKey]);
    
    PostData.WriteString(PostContent);
    PostData.Position := 0;
    
    HttpClient.ContentType := 'application/x-www-form-urlencoded';
    Response := HttpClient.Post(Config.ApiUrl, PostData);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if Assigned(JSONResponse) then
        begin
          // Parse DeepL translation response
          Result := JSONResponse.GetValue<string>('translations[0].text', '[ERROR] Invalid response');
        end;
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HttpClient.Free;
    PostData.Free;
  end;
end;

class function TTranslateAPI.TranslateFunction(const Text: string): string;
var
  Settings: TSettings;
  ApiName: string;
begin
  Result := '[ERROR] No API configured';
  
  Settings := TTranslator.Setting;
  if not Assigned(Settings) then
    Exit;
    
  ApiName := Settings.ApiName;
  FCurrentConfig := Settings.GetConfig(ApiName);
  
  // Route to appropriate translation function
  if ApiName = 'Google' then
    Result := TranslateGoogle(Text)
  else if ApiName = 'Google2' then
    Result := TranslateGoogle(Text)
  else if ApiName = 'DeepL' then
    Result := TranslateDeepL(Text)
  else if ApiName = 'Ollama' then
    Result := TranslateOllama(Text)
  else if ApiName = 'OpenAI' then
    Result := TranslateOpenAI(Text)
  else if ApiName = 'OpenRouter' then
    Result := TranslateOpenAI(Text) // OpenRouter uses OpenAI-compatible API
  else if ApiName = 'Youdao' then
    Result := TranslateYoudao(Text)
  else if ApiName = 'Baidu' then
    Result := TranslateBaidu(Text)
  else
    Result := '[ERROR] Unknown API provider: ' + ApiName;
end;

class function TTranslateAPI.TranslateGoogle(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  Url: string;
begin
  Result := '[ERROR] Translation failed';
  
  HttpClient := THttpClient.Create;
  try
    // Using Google Translate web interface (unofficial)
    // Note: This is simplified and may not work reliably
    Url := Format('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=%s',
      [TNetEncoding.URL.Encode(Text)]);
    
    Response := HttpClient.Get(Url);
    if Response.StatusCode = 200 then
    begin
      // Parse Google Translate response (simplified)
      // Full implementation would need proper JSON parsing
      Result := Response.ContentAsString;
      // This is a placeholder - real implementation needs proper parsing
      if Pos('[[', Result) = 1 then
        Result := 'Translated: ' + Text // Simplified result
      else
        Result := '[ERROR] Invalid response from Google';
    end;
  finally
    HttpClient.Free;
  end;
end;

class function TTranslateAPI.TranslateOllama(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  RequestBody: TJSONObject;
  PostData: TStringStream;
  JSONResponse: TJSONObject;
  Config: TOllamaConfig;
  Prompt: string;
  Settings: TSettings;
begin
  Result := '[ERROR] Translation failed';
  
  if not (FCurrentConfig is TOllamaConfig) then
    Exit;
    
  Config := FCurrentConfig as TOllamaConfig;
  Settings := TTranslator.Setting;
  
  HttpClient := THttpClient.Create;
  RequestBody := TJSONObject.Create;
  PostData := TStringStream.Create('', TEncoding.UTF8);
  try
    // Prepare the prompt
    if Assigned(Settings) then
      Prompt := Format(Settings.Prompt, [Settings.TargetLanguage])
    else
      Prompt := 'Translate the following text to Chinese: ';
    
    RequestBody.AddPair('model', Config.ModelName);
    RequestBody.AddPair('prompt', Prompt + '🔤' + Text + '🔤');
    RequestBody.AddPair('stream', TJSONBool.Create(False));
    RequestBody.AddPair('options', TJSONObject.Create.AddPair('temperature', TJSONNumber.Create(Config.Temperature)));
    
    PostData.WriteString(RequestBody.ToString);
    PostData.Position := 0;
    
    HttpClient.ContentType := 'application/json';
    Response := HttpClient.Post(Format('http://localhost:%d/api/generate', [Config.Port]), PostData);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if Assigned(JSONResponse) then
          Result := JSONResponse.GetValue<string>('response', '[ERROR] Invalid response');
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HttpClient.Free;
    RequestBody.Free;
    PostData.Free;
  end;
end;

class function TTranslateAPI.TranslateOpenAI(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  RequestBody: TJSONObject;
  PostData: TStringStream;
  JSONResponse: TJSONObject;
  Config: TOpenAIConfig;
  Messages: TJSONArray;
  Message: TJSONObject;
  Prompt: string;
  Settings: TSettings;
begin
  Result := '[ERROR] Translation failed';
  
  if not (FCurrentConfig is TOpenAIConfig) then
    Exit;
    
  Config := FCurrentConfig as TOpenAIConfig;
  if (Config.ApiKey = '') or (Config.ApiUrl = '') then
    Exit;
    
  Settings := TTranslator.Setting;
  
  HttpClient := THttpClient.Create;
  RequestBody := TJSONObject.Create;
  PostData := TStringStream.Create('', TEncoding.UTF8);
  Messages := TJSONArray.Create;
  try
    // Prepare the prompt
    if Assigned(Settings) then
      Prompt := Format(Settings.Prompt, [Settings.TargetLanguage])
    else
      Prompt := 'Translate the following text to Chinese: ';
    
    Message := TJSONObject.Create;
    Message.AddPair('role', 'user');
    Message.AddPair('content', Prompt + '🔤' + Text + '🔤');
    Messages.AddElement(Message);
    
    RequestBody.AddPair('model', Config.ModelName);
    RequestBody.AddPair('messages', Messages);
    RequestBody.AddPair('temperature', TJSONNumber.Create(1.0));
    
    PostData.WriteString(RequestBody.ToString);
    PostData.Position := 0;
    
    HttpClient.ContentType := 'application/json';
    HttpClient.CustomHeaders['Authorization'] := 'Bearer ' + Config.ApiKey;
    
    Response := HttpClient.Post(Config.ApiUrl + '/chat/completions', PostData);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if Assigned(JSONResponse) then
          Result := JSONResponse.GetValue<string>('choices[0].message.content', '[ERROR] Invalid response');
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HttpClient.Free;
    RequestBody.Free;
    PostData.Free;
  end;
end;

class function TTranslateAPI.TranslateYoudao(const Text: string): string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  PostData: TStringStream;
  JSONResponse: TJSONObject;
  Config: TYoudaoConfig;
  Salt, CurTime, Sign, PostContent: string;
begin
  Result := '[ERROR] Translation failed';
  
  if not (FCurrentConfig is TYoudaoConfig) then
    Exit;
    
  Config := FCurrentConfig as TYoudaoConfig;
  if (Config.AppKey = '') or (Config.AppSecret = '') then
    Exit;
  
  HttpClient := THttpClient.Create;
  PostData := TStringStream.Create('', TEncoding.UTF8);
  try
    // Generate required parameters for Youdao API
    Salt := IntToStr(Random(10000) + 1000);
    CurTime := IntToStr(DateTimeToUnix(Now));
    Sign := THashSHA256.GetHashString(Config.AppKey + Text + Salt + CurTime + Config.AppSecret);
    
    PostContent := Format('q=%s&from=auto&to=zh-CHS&appKey=%s&salt=%s&sign=%s&signType=v3&curtime=%s',
      [TNetEncoding.URL.Encode(Text),
       Config.AppKey,
       Salt,
       Sign,
       CurTime]);
    
    PostData.WriteString(PostContent);
    PostData.Position := 0;
    
    HttpClient.ContentType := 'application/x-www-form-urlencoded';
    Response := HttpClient.Post(Config.ApiUrl, PostData);
    
    if Response.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
      try
        if Assigned(JSONResponse) then
        begin
          // Parse Youdao translation response
          Result := JSONResponse.GetValue<string>('translation[0]', '[ERROR] Invalid response');
        end;
      finally
        JSONResponse.Free;
      end;
    end;
  finally
    HttpClient.Free;
    PostData.Free;
  end;
end;

end.