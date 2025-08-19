unit UpdateUtilUnit;

interface

uses
  System.SysUtils, System.Classes;

type
  TUpdateUtil = class
  private
    const GitHubReleasesUrl = 'https://github.com/SakiRinn/LiveCaptions-Translator/releases';
  public
    class function GetLatestVersion: string;
    class function GetGitHubReleasesUrl: string;
  end;

implementation

uses
  System.Net.HttpClient, System.JSON;

{ TUpdateUtil }

class function TUpdateUtil.GetGitHubReleasesUrl: string;
begin
  Result := GitHubReleasesUrl;
end;

class function TUpdateUtil.GetLatestVersion: string;
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  JSONResponse: TJSONObject;
begin
  Result := '';
  
  HttpClient := THttpClient.Create;
  try
    try
      // Get latest release info from GitHub API
      Response := HttpClient.Get('https://api.github.com/repos/SakiRinn/LiveCaptions-Translator/releases/latest');
      
      if Response.StatusCode = 200 then
      begin
        JSONResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
        try
          if Assigned(JSONResponse) then
            Result := JSONResponse.GetValue<string>('tag_name', '');
        finally
          JSONResponse.Free;
        end;
      end;
    except
      on E: Exception do
        raise Exception.Create('Failed to check for updates: ' + E.Message);
    end;
  finally
    HttpClient.Free;
  end;
end;

end.