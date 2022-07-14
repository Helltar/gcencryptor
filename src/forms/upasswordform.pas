unit uPasswordForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Dialogs, StdCtrls;

type

  { TfrmPassword }

  TfrmPassword = class(TForm)
    btnOK: TButton;
    btnShowPass: TButton;
    edtPassword: TEdit;
    lblPassword: TLabel;
    lblVault: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnShowPassClick(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
  end;

implementation

uses
  uMainForm;

{$R *.lfm}

{ TfrmPassword }

procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
  frmMain.vaultPassword := edtPassword.Text;
  edtPassword.Clear;
  Close;
end;

procedure TfrmPassword.btnShowPassClick(Sender: TObject);
begin
  if edtPassword.EchoMode = emPassword then
    edtPassword.EchoMode := emNormal
  else
    edtPassword.EchoMode := emPassword;
end;

procedure TfrmPassword.edtPasswordChange(Sender: TObject);
begin
  btnOK.Enabled := edtPassword.Text <> '';
end;

end.
