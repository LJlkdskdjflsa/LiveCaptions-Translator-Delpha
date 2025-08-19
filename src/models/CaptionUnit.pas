unit CaptionUnit;

interface

uses
  Classes, System.Generics.Collections, System.SysUtils, TranslationHistoryUnit,
  TranslatorUnit;

type
  TCaption = class
  private
    class var FInstance: TCaption;
    FOriginalCaption: string;
    FTranslatedCaption: string;
    FDisplayOriginalCaption: string;
    FDisplayTranslatedCaption: string;
    FOverlayOriginalCaption: string;
    FOverlayTranslatedCaption: string;
    FContexts: TQueue<TTranslationHistoryEntry>;
    FOnPropertyChanged: TNotifyEvent;
    
    procedure SetDisplayOriginalCaption(const Value: string);
    procedure SetDisplayTranslatedCaption(const Value: string);
    procedure SetOverlayOriginalCaption(const Value: string);
    procedure SetOverlayTranslatedCaption(const Value: string);
    procedure DoPropertyChanged;
  public
    constructor Create;
    destructor Destroy; override;
    
    class function GetInstance: TCaption;
    class procedure ReleaseInstance;
    
    property OriginalCaption: string read FOriginalCaption write FOriginalCaption;
    property TranslatedCaption: string read FTranslatedCaption write FTranslatedCaption;
    property DisplayOriginalCaption: string read FDisplayOriginalCaption write SetDisplayOriginalCaption;
    property DisplayTranslatedCaption: string read FDisplayTranslatedCaption write SetDisplayTranslatedCaption;
    property OverlayOriginalCaption: string read FOverlayOriginalCaption write SetOverlayOriginalCaption;
    property OverlayTranslatedCaption: string read FOverlayTranslatedCaption write SetOverlayTranslatedCaption;
    property Contexts: TQueue<TTranslationHistoryEntry> read FContexts;
    property OnPropertyChanged: TNotifyEvent read FOnPropertyChanged write FOnPropertyChanged;
    
    function GetPreviousCaption(Count: Integer): string;
    function GetPreviousTranslation(Count: Integer): string;
    function GetContextPreviousCaption: string;
    function GetOverlayPreviousTranslation: string;
  end;

implementation

uses
  TextUtilUnit, Math;

{ TCaption }

constructor TCaption.Create;
begin
  inherited;
  FContexts := TQueue<TTranslationHistoryEntry>.Create;
  FOriginalCaption := '';
  FTranslatedCaption := '';
  FDisplayOriginalCaption := '';
  FDisplayTranslatedCaption := '';
  FOverlayOriginalCaption := '';
  FOverlayTranslatedCaption := '';
end;

destructor TCaption.Destroy;
begin
  FContexts.Free;
  inherited;
end;

procedure TCaption.DoPropertyChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged(Self);
end;

class function TCaption.GetInstance: TCaption;
begin
  if not Assigned(FInstance) then
    FInstance := TCaption.Create;
  Result := FInstance;
end;

function TCaption.GetContextPreviousCaption: string;
var
  MaxCount: Integer;
begin
  if Assigned(TTranslator.Setting) and Assigned(TTranslator.Setting.MainWindow) then
    MaxCount := TTranslator.Setting.MainWindow.CaptionLogMax
  else
    MaxCount := 2;
  Result := GetPreviousCaption(Min(MaxCount, FContexts.Count));
end;

function TCaption.GetOverlayPreviousTranslation: string;
var
  MaxCount: Integer;
begin
  if Assigned(TTranslator.Setting) and Assigned(TTranslator.Setting.OverlayWindow) then
    MaxCount := TTranslator.Setting.OverlayWindow.HistoryMax
  else
    MaxCount := 1;
  Result := GetPreviousTranslation(Min(MaxCount, FContexts.Count));
end;

function TCaption.GetPreviousCaption(Count: Integer): string;
var
  ContextArray: TArray<TTranslationHistoryEntry>;
  I: Integer;
  Entry: TTranslationHistoryEntry;
  LastChar: Char;
begin
  Result := '';
  if Count <= 0 then
    Exit;
    
  ContextArray := FContexts.ToArray;
  
  // Reverse the array to get oldest first
  for I := Min(Count, Length(ContextArray)) - 1 downto 0 do
  begin
    Entry := ContextArray[I];
    if Result <> '' then
    begin
      if Length(Result) > 0 then
      begin
        LastChar := Result[Length(Result)];
        if not TTextUtil.IsEndOfSentence(LastChar) then
        begin
          if TTextUtil.IsCJChar(LastChar) then
            Result := Result + '。'
          else
            Result := Result + '. ';
        end;
      end;
    end;
    Result := Result + Entry.SourceText;
  end;
  
  // Add final punctuation if needed
  if (Result <> '') and (Length(Result) > 0) then
  begin
    LastChar := Result[Length(Result)];
    if not TTextUtil.IsEndOfSentence(LastChar) then
    begin
      if TTextUtil.IsCJChar(LastChar) then
        Result := Result + '。'
      else
        Result := Result + '.';
    end;
    if not TTextUtil.IsCJChar(LastChar) then
      Result := Result + ' ';
  end;
end;

function TCaption.GetPreviousTranslation(Count: Integer): string;
var
  ContextArray: TArray<TTranslationHistoryEntry>;
  I: Integer;
  Entry: TTranslationHistoryEntry;
  LastChar: Char;
  TransText: string;
begin
  Result := '';
  if Count <= 0 then
    Exit;
    
  ContextArray := FContexts.ToArray;
  
  // Reverse the array to get oldest first
  for I := Min(Count, Length(ContextArray)) - 1 downto 0 do
  begin
    Entry := ContextArray[I];
    TransText := Entry.TranslatedText;
    
    // Skip error and warning messages
    if (Pos('[ERROR]', TransText) > 0) or (Pos('[WARNING]', TransText) > 0) then
      Continue;
      
    if Result <> '' then
    begin
      if Length(Result) > 0 then
      begin
        LastChar := Result[Length(Result)];
        if not TTextUtil.IsEndOfSentence(LastChar) then
        begin
          if TTextUtil.IsCJChar(LastChar) then
            Result := Result + '。'
          else
            Result := Result + '. ';
        end;
      end;
    end;
    
    // Remove notice prefix patterns
    TransText := TTextUtil.RemoveNoticePrefix(TransText);
    Result := Result + TransText;
  end;
  
  // Remove notice prefix patterns from final result
  Result := TTextUtil.RemoveNoticePrefix(Result);
  
  // Add final punctuation if needed
  if (Result <> '') and (Length(Result) > 0) then
  begin
    LastChar := Result[Length(Result)];
    if not TTextUtil.IsEndOfSentence(LastChar) then
    begin
      if TTextUtil.IsCJChar(LastChar) then
        Result := Result + '。'
      else
        Result := Result + '.';
    end;
    if not TTextUtil.IsCJChar(LastChar) then
      Result := Result + ' ';
  end;
end;

class procedure TCaption.ReleaseInstance;
begin
  if Assigned(FInstance) then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

procedure TCaption.SetDisplayOriginalCaption(const Value: string);
begin
  if FDisplayOriginalCaption <> Value then
  begin
    FDisplayOriginalCaption := Value;
    DoPropertyChanged;
  end;
end;

procedure TCaption.SetDisplayTranslatedCaption(const Value: string);
begin
  if FDisplayTranslatedCaption <> Value then
  begin
    FDisplayTranslatedCaption := Value;
    DoPropertyChanged;
  end;
end;

procedure TCaption.SetOverlayOriginalCaption(const Value: string);
begin
  if FOverlayOriginalCaption <> Value then
  begin
    FOverlayOriginalCaption := Value;
    DoPropertyChanged;
  end;
end;

procedure TCaption.SetOverlayTranslatedCaption(const Value: string);
begin
  if FOverlayTranslatedCaption <> Value then
  begin
    FOverlayTranslatedCaption := Value;
    DoPropertyChanged;
  end;
end;

end.