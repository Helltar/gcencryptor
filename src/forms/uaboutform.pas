unit uAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Graphics, Dialogs, StdCtrls, LCLIntf;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    lblGocryptfs: TLabel;
    lblHomepage: TLabel;
    lblGithub: TLabel;
    memAbout: TMemo;
    procedure FormShow(Sender: TObject);
    procedure lblGocryptfsClick(Sender: TObject);
    procedure lblHomepageClick(Sender: TObject);
    procedure lblGithubClick(Sender: TObject);
  private

  public

  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.lblHomepageClick(Sender: TObject);
begin
  OpenURL(lblHomepage.Caption);
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
end;

procedure TfrmAbout.lblGocryptfsClick(Sender: TObject);
begin
  OpenURL(lblGocryptfs.Caption);
end;

procedure TfrmAbout.lblGithubClick(Sender: TObject);
begin
  OpenURL(lblGithub.Caption);
end;

end.
