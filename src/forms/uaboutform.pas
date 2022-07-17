unit uAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Graphics, Dialogs, StdCtrls, LCLIntf, ExtCtrls, Classes, Controls, LCLType;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    imgLogo: TImage;
    lblPapirus: TLabel;
    lblLicense: TLabel;
    lblGocryptfs: TLabel;
    lblHomepage: TLabel;
    lblGcencryptor: TLabel;
    stAbout: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure lblPapirusClick(Sender: TObject);
    procedure lblGcencryptorClick(Sender: TObject);
    procedure lblGocryptfsClick(Sender: TObject);
    procedure lblHomepageClick(Sender: TObject);
    procedure lblLicenseClick(Sender: TObject);
  end;

implementation

uses
  uUtils, uLicenseForm, uConsts;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := Height;
  Constraints.MaxWidth := Width;
end;

procedure TfrmAbout.lblPapirusClick(Sender: TObject);
begin
  OpenURL(URL_PAPIRUS);
end;

procedure TfrmAbout.lblGcencryptorClick(Sender: TObject);
begin
  OpenURL(URL_GCENCRYPTOR);
end;

procedure TfrmAbout.lblGocryptfsClick(Sender: TObject);
begin
  OpenURL(URL_GOCRYPTFS);
end;

procedure TfrmAbout.lblHomepageClick(Sender: TObject);
begin
  OpenURL(URL_HOMEPAGE);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  stAbout.Caption := getAppOriginalFilename() + ' - v' + getAppFileVersion() + LineEnding +
    getAppInfo('FileDescription');
end;

procedure TfrmAbout.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
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

end.
