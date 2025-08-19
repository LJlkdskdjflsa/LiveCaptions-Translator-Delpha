unit WelcomeForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfrmWelcome = class(TForm)
    pnlMain: TPanel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    btnGetStarted: TButton;
    btnClose: TButton;
    imgLogo: TImage;
    lblVersion: TLabel;
    procedure btnGetStartedClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  SettingsForm;

procedure TfrmWelcome.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmWelcome.btnGetStartedClick(Sender: TObject);
var
  SettingsForm: TfrmSettings;
begin
  // Show settings form
  SettingsForm := TfrmSettings.Create(Self);
  try
    if SettingsForm.ShowModal = mrOK then
      ModalResult := mrOK
    else
      ModalResult := mrCancel;
  finally
    SettingsForm.Free;
  end;
end;

procedure TfrmWelcome.FormCreate(Sender: TObject);
begin
  // Initialize welcome form
  lblVersion.Caption := 'Version 1.0.0';
end;

end.