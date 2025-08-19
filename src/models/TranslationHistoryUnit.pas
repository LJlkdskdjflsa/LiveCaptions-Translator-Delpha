unit TranslationHistoryUnit;

interface

uses
  System.SysUtils, System.DateUtils;

type
  TTranslationHistoryEntry = class
  private
    FSourceText: string;
    FTranslatedText: string;
    FTimestamp: TDateTime;
    FLatency: Int64;
  public
    constructor Create; overload;
    constructor Create(const ASourceText, ATranslatedText: string; ALatency: Int64 = 0); overload;
    
    property SourceText: string read FSourceText write FSourceText;
    property TranslatedText: string read FTranslatedText write FTranslatedText;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
    property Latency: Int64 read FLatency write FLatency;
    
    function ToJSON: string;
    procedure FromJSON(const JSONStr: string);
  end;

implementation

uses
  System.JSON;

{ TTranslationHistoryEntry }

constructor TTranslationHistoryEntry.Create;
begin
  inherited;
  FTimestamp := Now;
  FLatency := 0;
  FSourceText := '';
  FTranslatedText := '';
end;

constructor TTranslationHistoryEntry.Create(const ASourceText, ATranslatedText: string; ALatency: Int64);
begin
  Create;
  FSourceText := ASourceText;
  FTranslatedText := ATranslatedText;
  FLatency := ALatency;
end;

procedure TTranslationHistoryEntry.FromJSON(const JSONStr: string);
var
  JSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  try
    if Assigned(JSONObj) then
    begin
      FSourceText := JSONObj.GetValue<string>('SourceText', '');
      FTranslatedText := JSONObj.GetValue<string>('TranslatedText', '');
      FLatency := JSONObj.GetValue<Int64>('Latency', 0);
      FTimestamp := JSONObj.GetValue<TDateTime>('Timestamp', Now);
    end;
  finally
    JSONObj.Free;
  end;
end;

function TTranslationHistoryEntry.ToJSON: string;
var
  JSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('SourceText', FSourceText);
    JSONObj.AddPair('TranslatedText', FTranslatedText);
    JSONObj.AddPair('Latency', TJSONNumber.Create(FLatency));
    JSONObj.AddPair('Timestamp', TJSONString.Create(DateTimeToStr(FTimestamp)));
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

end.