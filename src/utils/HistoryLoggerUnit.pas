unit HistoryLoggerUnit;

interface

uses
  System.SysUtils, System.Classes, TranslationHistoryUnit, 
  System.Generics.Collections;

type
  THistoryLogger = class
  private
    class var FHistoryList: TList<TTranslationHistoryEntry>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure LogTranslation(const SourceText, TranslatedText, TargetLanguage, ApiName: string);
    class procedure DeleteLastTranslation;
    class function LoadLastTranslation: TTranslationHistoryEntry;
    class function LoadLastSourceText: string;
    class function LoadAllHistory: TList<TTranslationHistoryEntry>;
  end;

implementation

uses
  System.IOUtils, System.JSON;

{ THistoryLogger }

class constructor THistoryLogger.Create;
begin
  FHistoryList := TList<TTranslationHistoryEntry>.Create;
end;

class destructor THistoryLogger.Destroy;
var
  I: Integer;
begin
  if Assigned(FHistoryList) then
  begin
    for I := 0 to FHistoryList.Count - 1 do
      FHistoryList[I].Free;
    FHistoryList.Free;
  end;
end;

class procedure THistoryLogger.DeleteLastTranslation;
begin
  if FHistoryList.Count > 0 then
  begin
    FHistoryList.Last.Free;
    FHistoryList.Delete(FHistoryList.Count - 1);
  end;
end;

class function THistoryLogger.LoadAllHistory: TList<TTranslationHistoryEntry>;
begin
  Result := FHistoryList;
end;

class function THistoryLogger.LoadLastSourceText: string;
var
  LastEntry: TTranslationHistoryEntry;
begin
  Result := '';
  LastEntry := LoadLastTranslation;
  if Assigned(LastEntry) then
    Result := LastEntry.SourceText;
end;

class function THistoryLogger.LoadLastTranslation: TTranslationHistoryEntry;
begin
  Result := nil;
  if FHistoryList.Count > 0 then
    Result := FHistoryList.Last;
end;

class procedure THistoryLogger.LogTranslation(const SourceText, TranslatedText, TargetLanguage, ApiName: string);
var
  Entry: TTranslationHistoryEntry;
begin
  Entry := TTranslationHistoryEntry.Create(SourceText, TranslatedText);
  FHistoryList.Add(Entry);
  
  // Keep only last 1000 entries to prevent memory issues
  while FHistoryList.Count > 1000 do
  begin
    FHistoryList.First.Free;
    FHistoryList.Delete(0);
  end;
end;

end.