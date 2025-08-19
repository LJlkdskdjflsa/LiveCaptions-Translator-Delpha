unit TranslatorUnit;

interface

uses
  Classes, System.SysUtils, System.Generics.Collections, System.Threading,
  System.SyncObjs, Winapi.Windows, CaptionUnit, SettingUnit, 
  TranslationHistoryUnit, LiveCaptionsHandlerUnit, TranslateAPIUnit,
  TextUtilUnit;

type
  TTranslator = class
  private
    class var FInstance: TTranslator;
    class var FWindow: THandle;
    class var FCaption: TCaption;
    class var FSetting: TSettings;
    class var FLogOnlyFlag: Boolean;
    class var FFirstUseFlag: Boolean;
    class var FPendingTextQueue: TThreadedQueue<string>;
    class var FSyncLoopTask: ITask;
    class var FTranslateLoopTask: ITask;
    class var FDisplayLoopTask: ITask;
    class var FShutdownEvent: TEvent;
    
    class procedure InitializeTasks;
    class procedure SyncLoop;
    class procedure TranslateLoop;
    class procedure DisplayLoop;
  public
    class constructor Create;
    class destructor Destroy;
    
    class procedure Initialize;
    class procedure Shutdown;
    
    class function GetInstance: TTranslator;
    
    class property Window: THandle read FWindow write FWindow;
    class property Caption: TCaption read FCaption;
    class property Setting: TSettings read FSetting;
    class property LogOnlyFlag: Boolean read FLogOnlyFlag write FLogOnlyFlag;
    class property FirstUseFlag: Boolean read FFirstUseFlag write FFirstUseFlag;
    
    class function Translate(const Text: string): string;
    class procedure Log(const OriginalText, TranslatedText: string; IsOverwrite: Boolean = False);
    class procedure LogOnly(const OriginalText: string; IsOverwrite: Boolean = False);
    class function IsOverwrite(const OriginalText: string): Boolean;
  end;

implementation

uses
  System.IOUtils, Math, HistoryLoggerUnit;

{ TTranslator }

class constructor TTranslator.Create;
begin
  FLogOnlyFlag := False;
  FFirstUseFlag := False;
  FPendingTextQueue := TThreadedQueue<string>.Create(1024, 1, 100);
  FShutdownEvent := TEvent.Create(nil, True, False, '');
end;

class destructor TTranslator.Destroy;
begin
  Shutdown;
  FPendingTextQueue.Free;
  FShutdownEvent.Free;
  if Assigned(FSetting) then
    FSetting.Free;
  if Assigned(FCaption) then
    TCaption.ReleaseInstance;
  if Assigned(FInstance) then
    FInstance.Free;
end;

class procedure TTranslator.DisplayLoop;
var
  TranslatedText: string;
  IsChoke: Boolean;
begin
  while not FShutdownEvent.WaitFor(40) = wrSignaled do
  begin
    try
      if FLogOnlyFlag then
      begin
        if Assigned(FCaption) then
        begin
          FCaption.TranslatedCaption := '';
          FCaption.DisplayTranslatedCaption := '[Paused]';
          FCaption.OverlayTranslatedCaption := '[Paused]';
        end;
      end
      else
      begin
        // TODO: Implement display logic based on translation results
        // This would need integration with the translation task queue
      end;
    except
      on E: Exception do
        // Log error but continue
        Continue;
    end;
  end;
end;

class function TTranslator.GetInstance: TTranslator;
begin
  if not Assigned(FInstance) then
    FInstance := TTranslator.Create;
  Result := FInstance;
end;

class procedure TTranslator.Initialize;
begin
  // Launch LiveCaptions and get window handle
  FWindow := TLiveCaptionsHandler.LaunchLiveCaptions;
  TLiveCaptionsHandler.FixLiveCaptions(FWindow);
  TLiveCaptionsHandler.HideLiveCaptions(FWindow);
  
  // Check if first use
  if not TSettings.IsConfigExist then
    FFirstUseFlag := True;
    
  // Initialize caption and settings
  FCaption := TCaption.GetInstance;
  FSetting := TSettings.Load;
  
  // Start background tasks
  InitializeTasks;
end;

class procedure TTranslator.InitializeTasks;
begin
  // Start the three main loops as tasks
  FSyncLoopTask := TTask.Create(procedure
  begin
    SyncLoop;
  end);
  FSyncLoopTask.Start;
  
  FTranslateLoopTask := TTask.Create(procedure
  begin
    TranslateLoop;
  end);
  FTranslateLoopTask.Start;
  
  FDisplayLoopTask := TTask.Create(procedure
  begin
    DisplayLoop;
  end);
  FDisplayLoopTask.Start;
end;

class function TTranslator.IsOverwrite(const OriginalText: string): Boolean;
var
  LastOriginalText: string;
  Similarity: Double;
begin
  Result := False;
  try
    LastOriginalText := THistoryLogger.LoadLastSourceText;
    if LastOriginalText <> '' then
    begin
      Similarity := TTextUtil.Similarity(OriginalText, LastOriginalText);
      Result := Similarity > 0.66;
    end;
  except
    // If error occurs, assume no overwrite
    Result := False;
  end;
end;

class procedure TTranslator.Log(const OriginalText, TranslatedText: string; IsOverwrite: Boolean);
var
  TargetLanguage, ApiName: string;
begin
  try
    if Assigned(FSetting) then
    begin
      TargetLanguage := FSetting.TargetLanguage;
      ApiName := FSetting.ApiName;
    end
    else
    begin
      TargetLanguage := 'N/A';
      ApiName := 'N/A';
    end;
    
    if IsOverwrite then
      THistoryLogger.DeleteLastTranslation;
      
    THistoryLogger.LogTranslation(OriginalText, TranslatedText, TargetLanguage, ApiName);
  except
    on E: Exception do
      // Log error but don't throw
      OutputDebugString(PChar('[ERROR] Logging History Failed: ' + E.Message));
  end;
end;

class procedure TTranslator.LogOnly(const OriginalText: string; IsOverwrite: Boolean);
begin
  try
    if IsOverwrite then
      THistoryLogger.DeleteLastTranslation;
      
    THistoryLogger.LogTranslation(OriginalText, 'N/A', 'N/A', 'LogOnly');
  except
    on E: Exception do
      // Log error but don't throw
      OutputDebugString(PChar('[ERROR] Logging History Failed: ' + E.Message));
  end;
end;

class procedure TTranslator.Shutdown;
begin
  // Signal shutdown to all threads
  FShutdownEvent.SetEvent;
  
  // Wait for tasks to complete (with timeout)
  if Assigned(FSyncLoopTask) then
    FSyncLoopTask.Wait(5000);
  if Assigned(FTranslateLoopTask) then
    FTranslateLoopTask.Wait(5000);
  if Assigned(FDisplayLoopTask) then
    FDisplayLoopTask.Wait(5000);
end;

class procedure TTranslator.SyncLoop;
var
  IdleCount, SyncCount: Integer;
  FullText, LatestCaption: string;
  LastEOSIndex, LastEOS: Integer;
begin
  IdleCount := 0;
  SyncCount := 0;
  
  while not FShutdownEvent.WaitFor(25) = wrSignaled do
  begin
    try
      if FWindow = 0 then
      begin
        Sleep(2000);
        Continue;
      end;
      
      // Get text from LiveCaptions
      FullText := TLiveCaptionsHandler.GetCaptions(FWindow);
      if FullText = '' then
        Continue;
        
      // Preprocess text
      FullText := TTextUtil.PreprocessText(FullText);
      
      // Prevent adding the last sentence from previous running to log cards
      // before the first sentence is completed.
      if (Pos('.', FullText) = 0) and (Pos('!', FullText) = 0) and (Pos('?', FullText) = 0) and
         Assigned(FCaption) and (FCaption.Contexts.Count > 0) then
      begin
        FCaption.Contexts.Clear;
      end;
      
      // Get the last sentence
      LastEOSIndex := TTextUtil.GetLastSentenceStart(FullText);
      LatestCaption := Copy(FullText, LastEOSIndex + 1, Length(FullText));
      
      // If the last sentence is too short, extend it by adding the previous sentence
      if (LastEOSIndex > 0) and (TTextUtil.GetByteCount(LatestCaption) < TTextUtil.SHORT_THRESHOLD) then
      begin
        LastEOSIndex := TTextUtil.GetLastSentenceStart(Copy(FullText, 1, LastEOSIndex));
        LatestCaption := Copy(FullText, LastEOSIndex + 1, Length(FullText));
      end;
      
      // Update overlay original caption
      if Assigned(FCaption) then
      begin
        FCaption.OverlayOriginalCaption := LatestCaption;
        
        // Update display original caption
        if FCaption.DisplayOriginalCaption <> LatestCaption then
        begin
          FCaption.DisplayOriginalCaption := LatestCaption;
          FCaption.DisplayOriginalCaption := TTextUtil.ShortenDisplaySentence(
            FCaption.DisplayOriginalCaption, TTextUtil.VERYLONG_THRESHOLD);
        end;
        
        // Prepare for OriginalCaption. If expanded, only retain the complete sentence
        LastEOS := TTextUtil.GetLastSentenceEnd(LatestCaption);
        if LastEOS > 0 then
          LatestCaption := Copy(LatestCaption, 1, LastEOS);
          
        // Update OriginalCaption
        if FCaption.OriginalCaption <> LatestCaption then
        begin
          FCaption.OriginalCaption := LatestCaption;
          IdleCount := 0;
          
          if TTextUtil.IsCompleteSentence(FCaption.OriginalCaption) then
          begin
            SyncCount := 0;
            FPendingTextQueue.PushItem(FCaption.OriginalCaption);
          end
          else if TTextUtil.GetByteCount(FCaption.OriginalCaption) >= TTextUtil.SHORT_THRESHOLD then
            Inc(SyncCount);
        end
        else
          Inc(IdleCount);
          
        // Determine whether this sentence should be translated
        if Assigned(FSetting) and ((SyncCount > FSetting.MaxSyncInterval) or 
           (IdleCount = FSetting.MaxIdleInterval)) then
        begin
          SyncCount := 0;
          FPendingTextQueue.PushItem(FCaption.OriginalCaption);
        end;
      end;
    except
      on E: Exception do
      begin
        // Handle element not available exception
        if E.Message.Contains('ElementNotAvailable') then
          FWindow := 0;
        Continue;
      end;
    end;
  end;
end;

class function TTranslator.Translate(const Text: string): string;
var
  IsChoke: Boolean;
begin
  Result := '';
  IsChoke := TTextUtil.IsCompleteSentence(Text);
  
  try
    if Assigned(FSetting) and FSetting.ContextAware and not TTranslateAPI.IsLLMBased then
    begin
      Result := TTranslateAPI.TranslateFunction(FCaption.GetContextPreviousCaption + ' <[' + Text + ']>');
      // Extract target sentence from result
      Result := TTextUtil.ExtractTargetSentence(Result);
    end
    else
    begin
      Result := TTranslateAPI.TranslateFunction(Text);
      Result := StringReplace(Result, '🔤', '', [rfReplaceAll]);
    end;
    
    if Assigned(FSetting) and Assigned(FSetting.MainWindow) and FSetting.MainWindow.LatencyShow then
    begin
      // TODO: Add latency measurement
      // Result := '[' + IntToStr(latency) + ' ms] ' + Result;
    end;
  except
    on E: Exception do
    begin
      Result := '[ERROR] Translation Failed: ' + E.Message;
      OutputDebugString(PChar(Result));
    end;
  end;
end;

class procedure TTranslator.TranslateLoop;
var
  OriginalSnapshot: string;
  TranslatedText: string;
  IsOverwriteFlag: Boolean;
begin
  while not FShutdownEvent.WaitFor(40) = wrSignaled do
  begin
    try
      // Check LiveCaptions still alive
      if FWindow = 0 then
      begin
        if Assigned(FCaption) then
        begin
          FCaption.DisplayTranslatedCaption := '[WARNING] LiveCaptions was unexpectedly closed, restarting...';
          FWindow := TLiveCaptionsHandler.LaunchLiveCaptions;
          FCaption.DisplayTranslatedCaption := '';
        end;
      end;
      
      // Process pending translations
      if FPendingTextQueue.PopItem(OriginalSnapshot) = TWaitResult.wrSignaled then
      begin
        if FLogOnlyFlag then
        begin
          IsOverwriteFlag := IsOverwrite(OriginalSnapshot);
          LogOnly(OriginalSnapshot, IsOverwriteFlag);
        end
        else
        begin
          TranslatedText := Translate(OriginalSnapshot);
          IsOverwriteFlag := IsOverwrite(OriginalSnapshot);
          Log(OriginalSnapshot, TranslatedText, IsOverwriteFlag);
          
          // Update captions
          if Assigned(FCaption) and (TranslatedText <> '') then
          begin
            FCaption.TranslatedCaption := TranslatedText;
            FCaption.DisplayTranslatedCaption := TTextUtil.ShortenDisplaySentence(
              FCaption.TranslatedCaption, TTextUtil.VERYLONG_THRESHOLD);
              
            // Update overlay translated caption
            if (Pos('[ERROR]', FCaption.TranslatedCaption) > 0) or 
               (Pos('[WARNING]', FCaption.TranslatedCaption) > 0) then
              FCaption.OverlayTranslatedCaption := FCaption.TranslatedCaption
            else
            begin
              FCaption.OverlayTranslatedCaption := FCaption.GetOverlayPreviousTranslation + 
                TTextUtil.RemoveNoticePrefix(TranslatedText);
            end;
          end;
        end;
      end;
    except
      on E: Exception do
        Continue;
    end;
  end;
end;

end.