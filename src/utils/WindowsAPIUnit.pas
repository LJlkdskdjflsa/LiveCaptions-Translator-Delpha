unit WindowsAPIUnit;

interface

uses
  Winapi.Windows, System.SysUtils;

type
  TWindowsAPI = class
  public
    // Window manipulation functions
    class function FindWindowByTitle(const Title: string): HWND;
    class function FindWindowByClass(const ClassName: string): HWND;
    class function GetWindowTextStr(WindowHandle: HWND): string;
    class function SetWindowTextStr(WindowHandle: HWND; const Text: string): Boolean;
    class function IsWindowVisibleEx(WindowHandle: HWND): Boolean;
    class procedure ShowWindowEx(WindowHandle: HWND; ShowCmd: Integer);
    class procedure SetWindowPosEx(WindowHandle: HWND; X, Y, Width, Height: Integer; Flags: UINT);
    
    // Process functions
    class function GetProcessIdByWindow(WindowHandle: HWND): DWORD;
    class function TerminateProcessByPID(ProcessId: DWORD): Boolean;
    class function IsProcessRunning(const ProcessName: string): Boolean;
    
    // Accessibility functions
    class function GetAccessibleText(WindowHandle: HWND): string;
    class function GetChildWindows(ParentHandle: HWND): TArray<HWND>;
  end;

implementation

uses
  Winapi.TlHelp32, System.Classes, Winapi.ActiveX, Winapi.ComObj;

{ TWindowsAPI }

class function TWindowsAPI.FindWindowByClass(const ClassName: string): HWND;
begin
  Result := FindWindow(PChar(ClassName), nil);
end;

class function TWindowsAPI.FindWindowByTitle(const Title: string): HWND;
begin
  Result := FindWindow(nil, PChar(Title));
end;

class function TWindowsAPI.GetAccessibleText(WindowHandle: HWND): string;
begin
  // This is a placeholder for accessibility text extraction
  // Real implementation would use UI Automation or MSAA
  Result := '';
  
  if WindowHandle <> 0 then
  begin
    // TODO: Implement UI Automation to get accessible text
    // This would involve:
    // 1. Creating UI Automation client
    // 2. Getting automation element from window handle
    // 3. Finding text patterns or value patterns
    // 4. Extracting the text content
    
    // For now, just return window text as fallback
    Result := GetWindowTextStr(WindowHandle);
  end;
end;

class function TWindowsAPI.GetChildWindows(ParentHandle: HWND): TArray<HWND>;
var
  WindowList: TList<HWND>;
  
  function EnumChildProc(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
  var
    List: TList<HWND>;
  begin
    List := TList<HWND>(lParam);
    List.Add(hwnd);
    Result := True;
  end;
  
begin
  WindowList := TList<HWND>.Create;
  try
    EnumChildWindows(ParentHandle, @EnumChildProc, LPARAM(WindowList));
    Result := WindowList.ToArray;
  finally
    WindowList.Free;
  end;
end;

class function TWindowsAPI.GetProcessIdByWindow(WindowHandle: HWND): DWORD;
begin
  GetWindowThreadProcessId(WindowHandle, @Result);
end;

class function TWindowsAPI.GetWindowTextStr(WindowHandle: HWND): string;
var
  Buffer: array[0..1023] of Char;
  Len: Integer;
begin
  Result := '';
  if WindowHandle <> 0 then
  begin
    Len := GetWindowText(WindowHandle, Buffer, Length(Buffer));
    if Len > 0 then
      Result := string(Buffer);
  end;
end;

class function TWindowsAPI.IsProcessRunning(const ProcessName: string): Boolean;
var
  Snapshot: THandle;
  ProcessEntry: TProcessEntry32;
  Found: Boolean;
begin
  Result := False;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot <> INVALID_HANDLE_VALUE then
  try
    ProcessEntry.dwSize := SizeOf(ProcessEntry);
    Found := Process32First(Snapshot, ProcessEntry);
    while Found do
    begin
      if SameText(ProcessEntry.szExeFile, ProcessName) then
      begin
        Result := True;
        Break;
      end;
      Found := Process32Next(Snapshot, ProcessEntry);
    end;
  finally
    CloseHandle(Snapshot);
  end;
end;

class function TWindowsAPI.IsWindowVisibleEx(WindowHandle: HWND): Boolean;
begin
  Result := IsWindowVisible(WindowHandle);
end;

class function TWindowsAPI.SetWindowTextStr(WindowHandle: HWND; const Text: string): Boolean;
begin
  Result := SetWindowText(WindowHandle, PChar(Text));
end;

class procedure TWindowsAPI.SetWindowPosEx(WindowHandle: HWND; X, Y, Width, Height: Integer; Flags: UINT);
begin
  SetWindowPos(WindowHandle, 0, X, Y, Width, Height, Flags);
end;

class procedure TWindowsAPI.ShowWindowEx(WindowHandle: HWND; ShowCmd: Integer);
begin
  ShowWindow(WindowHandle, ShowCmd);
end;

class function TWindowsAPI.TerminateProcessByPID(ProcessId: DWORD): Boolean;
var
  ProcessHandle: THandle;
begin
  Result := False;
  ProcessHandle := OpenProcess(PROCESS_TERMINATE, False, ProcessId);
  if ProcessHandle <> 0 then
  try
    Result := TerminateProcess(ProcessHandle, 0);
  finally
    CloseHandle(ProcessHandle);
  end;
end;

end.