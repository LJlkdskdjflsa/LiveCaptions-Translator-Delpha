unit WindowHandlerUnit;

interface

uses
  Vcl.Forms, System.Classes, System.SysUtils, SettingUnit;

type
  TWindowHandler = class
  public
    class function LoadState(Window: TForm; Settings: TSettings): string;
    class procedure RestoreState(Window: TForm; const State: string);
    class procedure SaveState(Window: TForm; Settings: TSettings);
  end;

implementation

uses
  System.Math;

{ TWindowHandler }

class function TWindowHandler.LoadState(Window: TForm; Settings: TSettings): string;
var
  WindowName: string;
begin
  Result := '';
  if not Assigned(Window) or not Assigned(Settings) then
    Exit;
    
  WindowName := Window.ClassName;
  if WindowName = 'TfrmMain' then
    WindowName := 'MainWindow'
  else if WindowName = 'TfrmOverlay' then
    WindowName := 'OverlayWindow';
    
  if Settings.WindowBounds.ContainsKey(WindowName) then
    Result := Settings.WindowBounds[WindowName];
end;

class procedure TWindowHandler.RestoreState(Window: TForm; const State: string);
var
  Parts: TArray<string>;
  Left, Top, Width, Height: Integer;
begin
  if not Assigned(Window) or (State = '') then
    Exit;
    
  Parts := State.Split([',']);
  if Length(Parts) >= 4 then
  begin
    Left := StrToIntDef(Trim(Parts[0]), Window.Left);
    Top := StrToIntDef(Trim(Parts[1]), Window.Top);
    Width := StrToIntDef(Trim(Parts[2]), Window.Width);
    Height := StrToIntDef(Trim(Parts[3]), Window.Height);
    
    // Ensure window is visible on screen
    Left := Max(0, Min(Left, Screen.Width - Width));
    Top := Max(0, Min(Top, Screen.Height - Height));
    
    Window.SetBounds(Left, Top, Width, Height);
  end;
end;

class procedure TWindowHandler.SaveState(Window: TForm; Settings: TSettings);
var
  WindowName: string;
  State: string;
begin
  if not Assigned(Window) or not Assigned(Settings) then
    Exit;
    
  WindowName := Window.ClassName;
  if WindowName = 'TfrmMain' then
    WindowName := 'MainWindow'
  else if WindowName = 'TfrmOverlay' then
    WindowName := 'OverlayWindow';
    
  State := Format('%d, %d, %d, %d', [Window.Left, Window.Top, Window.Width, Window.Height]);
  Settings.WindowBounds.AddOrSetValue(WindowName, State);
  Settings.Save;
end;

end.