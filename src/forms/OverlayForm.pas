unit OverlayForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  TranslatorUnit, SettingUnit, WindowHandlerUnit, CaptionUnit;

type
  TfrmOverlay = class(TForm)
    pnlBackground: TPanel;
    lblOriginal: TLabel;
    lblTranslated: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WMMove(var Message: TMessage); message WM_MOVE;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
  private
    FSettings: TSettings;
    FOnlyMode: Integer;
    
    procedure LoadSettings;
    procedure ApplyOverlaySettings;
    procedure SaveWindowState;
    procedure OnCaptionChanged(Sender: TObject);
    procedure UpdateCaptions;
  public
    property OnlyMode: Integer read FOnlyMode write FOnlyMode;
  end;

implementation

{$R *.dfm}

uses
  Math;

procedure TfrmOverlay.ApplyOverlaySettings;
var
  OverlaySettings: TOverlayWindowState;
begin
  if not Assigned(FSettings) or not Assigned(FSettings.OverlayWindow) then
    Exit;
    
  OverlaySettings := FSettings.OverlayWindow;
  
  // Apply font settings
  lblOriginal.Font.Size := OverlaySettings.FontSize;
  lblTranslated.Font.Size := OverlaySettings.FontSize;
  
  // Apply font style
  if OverlaySettings.FontBold = 1 then
  begin
    lblOriginal.Font.Style := [fsBold];
    lblTranslated.Font.Style := [fsBold];
  end
  else
  begin
    lblOriginal.Font.Style := [];
    lblTranslated.Font.Style := [];
  end;
  
  // Apply colors (simplified color mapping)
  case OverlaySettings.FontColor of
    0: begin
      lblOriginal.Font.Color := clWhite;
      lblTranslated.Font.Color := clWhite;
    end;
    1: begin
      lblOriginal.Font.Color := clBlack;
      lblTranslated.Font.Color := clBlack;
    end;
    else begin
      lblOriginal.Font.Color := clWindowText;
      lblTranslated.Font.Color := clWindowText;
    end;
  end;
  
  // Apply background color and opacity
  case OverlaySettings.BackgroundColor of
    0: pnlBackground.Color := clBlack;
    1: pnlBackground.Color := clWhite;
    8: pnlBackground.Color := clGray;
    else pnlBackground.Color := clBtnFace;
  end;
  
  // Apply transparency (simplified - Delphi XE 7 has limited alpha blending support)
  AlphaBlend := True;
  AlphaBlendValue := OverlaySettings.Opacity;
end;

procedure TfrmOverlay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveWindowState;
end;

procedure TfrmOverlay.FormCreate(Sender: TObject);
begin
  FSettings := TTranslator.Setting;
  FOnlyMode := 0;
  
  // Set up overlay window properties
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  Color := clFuchsia;
  TransparentColor := True;
  TransparentColorValue := clFuchsia;
  
  LoadSettings;
  ApplyOverlaySettings;
  
  // Set up caption change notification
  if Assigned(TCaption.GetInstance) then
    TCaption.GetInstance.OnPropertyChanged := OnCaptionChanged;
end;

procedure TfrmOverlay.FormDestroy(Sender: TObject);
begin
  // Clean up
end;

procedure TfrmOverlay.FormShow(Sender: TObject);
begin
  UpdateCaptions;
end;

procedure TfrmOverlay.LoadSettings;
var
  WindowState: string;
  Bounds: TStringList;
begin
  if Assigned(FSettings) and FSettings.WindowBounds.ContainsKey('OverlayWindow') then
  begin
    WindowState := FSettings.WindowBounds['OverlayWindow'];
    Bounds := TStringList.Create;
    try
      Bounds.CommaText := WindowState;
      if Bounds.Count >= 4 then
      begin
        Left := StrToIntDef(Bounds[0], Left);
        Top := StrToIntDef(Bounds[1], Top);
        Width := StrToIntDef(Bounds[2], Width);
        Height := StrToIntDef(Bounds[3], Height);
      end;
    finally
      Bounds.Free;
    end;
  end;
end;

procedure TfrmOverlay.OnCaptionChanged(Sender: TObject);
begin
  UpdateCaptions;
end;

procedure TfrmOverlay.SaveWindowState;
var
  WindowState: string;
begin
  if Assigned(FSettings) then
  begin
    WindowState := Format('%d, %d, %d, %d', [Left, Top, Width, Height]);
    FSettings.WindowBounds.AddOrSetValue('OverlayWindow', WindowState);
    FSettings.Save;
  end;
end;

procedure TfrmOverlay.UpdateCaptions;
var
  Caption: TCaption;
begin
  Caption := TCaption.GetInstance;
  if Assigned(Caption) then
  begin
    case FOnlyMode of
      0: begin // Both original and translated
        lblOriginal.Caption := Caption.OverlayOriginalCaption;
        lblTranslated.Caption := Caption.OverlayTranslatedCaption;
        lblOriginal.Visible := True;
        lblTranslated.Visible := True;
      end;
      1: begin // Only original
        lblOriginal.Caption := Caption.OverlayOriginalCaption;
        lblOriginal.Visible := True;
        lblTranslated.Visible := False;
      end;
      2: begin // Only translated
        lblTranslated.Caption := Caption.OverlayTranslatedCaption;
        lblOriginal.Visible := False;
        lblTranslated.Visible := True;
      end;
    end;
  end;
end;

procedure TfrmOverlay.WMMove(var Message: TMessage);
begin
  inherited;
  SaveWindowState;
end;

procedure TfrmOverlay.WMSize(var Message: TMessage);
begin
  inherited;
  SaveWindowState;
end;

end.