unit uPasswordForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, Dialogs, StdCtrls, Classes, Controls, LCLType;

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
    procedure edtPasswordKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
  private
    procedure okClose();
  end;

implementation

uses
  uMainForm, uConsts;

{$R *.lfm}

{ TfrmPassword }

procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
  okClose();
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

procedure TfrmPassword.edtPasswordKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    okClose();
end;

procedure TfrmPassword.FormCreate(Sender: TObject);
begin
  Caption := APP_NAME;
end;

procedure TfrmPassword.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
end;

procedure TfrmPassword.okClose;
begin
  frmMain.vaultPassword := edtPassword.Text;
  edtPassword.Clear;
  Close;
end;

end.
