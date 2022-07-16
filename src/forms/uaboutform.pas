unit uAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Graphics, Dialogs, StdCtrls, LCLIntf, ExtCtrls, Classes, Controls, LCLType;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    imgLogo: TImage;
    lblLicense: TLabel;
    lblGocryptfs: TLabel;
    lblHomepage: TLabel;
    lblGithub: TLabel;
    stAbout: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure imgLogoDblClick(Sender: TObject);
    procedure lblLicenseClick(Sender: TObject);
    procedure lblClick(Sender: TObject);
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  uUtils, uLicenseForm;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := Height;
  Constraints.MaxWidth := Width;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  stAbout.Caption :=
    getAppOriginalFilename() + ' - v' + getAppFileVersion() + LineEnding +
    getAppInfo('FileDescription');
end;

procedure TfrmAbout.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
end;

procedure TfrmAbout.imgLogoDblClick(Sender: TObject);
begin
  OpenURL(lblGithub.Caption);
end;

procedure TfrmAbout.lblLicenseClick(Sender: TObject);
begin
  with TfrmLicense.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmAbout.lblClick(Sender: TObject);
begin
  OpenURL(TLabel(Sender).Caption);
end;

end.
