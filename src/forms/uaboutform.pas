unit uAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Graphics, Dialogs, StdCtrls, LCLIntf, ExtCtrls, Classes, fileinfo;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    imgLogo: TImage;
    lblGocryptfs: TLabel;
    lblHomepage: TLabel;
    lblGithub: TLabel;
    stAbout: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgLogoDblClick(Sender: TObject);
    procedure lblClick(Sender: TObject);
  private
    function getAppVersion(const AType: string): string;
  end;

var
  frmAbout: TfrmAbout;

implementation

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
    getAppVersion('OriginalFilename') + ' - v' + getAppVersion('FileVersion') + LineEnding +
    getAppVersion('FileDescription') + LineEnding +
    'License: MIT';
  {
    ['CompanyName'] ['FileDescription'] ['FileVersion']
    ['InternalName'] ['LegalCopyright'] ['OriginalFilename']
    ['ProductName'] ['ProductVersion']
  }
end;

procedure TfrmAbout.imgLogoDblClick(Sender: TObject);
begin
  OpenURL(lblGithub.Caption);
end;

procedure TfrmAbout.lblClick(Sender: TObject);
begin
  OpenURL(TLabel(Sender).Caption);
end;

function TfrmAbout.getAppVersion(const AType: string): string;
begin
  Result := '-1';
  with TFileVersionInfo.Create(nil) do
    try
      ReadFileInfo;
      Result := VersionStrings.Values[AType];
    finally
      Free;
    end;
end;

end.
