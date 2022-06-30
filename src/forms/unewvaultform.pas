unit uNewVaultForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn;

type

  { TfrmNewVault }

  TfrmNewVault = class(TForm)
    btnCreate: TButton;
    edtPath: TDirectoryEdit;
    edtVaultName: TEdit;
    edtPassword: TEdit;
    edtRepeatPassword: TEdit;
    procedure btnCreateClick(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
    procedure edtPathChange(Sender: TObject);
    procedure edtRepeatPasswordChange(Sender: TObject);
    procedure edtVaultNameChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure createVault(const path: string);
    procedure updateControls();
  end;

implementation

uses
  ugocryptfs, uMainForm, uMasterKeyForm;

resourcestring
  PASSWORDS_DO_NOT_MATCH = 'Passwords do not match';
  DIRECTORY_EXISTS = 'Directory already exists';

{$R *.lfm}

{ TfrmNewVault }

procedure TfrmNewVault.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := 700;
end;

procedure TfrmNewVault.btnCreateClick(Sender: TObject);
var
  path: string;

begin
  path := edtPath.Directory + DirectorySeparator + edtVaultName.Text;

  if edtPassword.Text <> edtRepeatPassword.Text then
    ShowMessage(PASSWORDS_DO_NOT_MATCH)
  else
  if DirectoryExists(path) then
    ShowMessage(DIRECTORY_EXISTS + ': ' + path)
  else
    createVault(path);
end;


procedure TfrmNewVault.createVault(const path: string);
var
  xRay: TInitRec;

begin
  edtRepeatPassword.Clear;

  if init(edtVaultName.Text, edtPath.Directory, edtPassword.Text) then
  begin
    frmMain.addVaultToList(path);

    xRay := dumpMasterKey(path, edtPassword.Text);
    edtPassword.Clear;

    if xRay.Completed then
      with TfrmMasterKey.Create(Self) do
        try
          edtKey.Text := xRay.Output;
          vaultName := edtVaultName.Text;
          xRay.Output := '';
          ShowModal;
        finally
          Free;
        end;
  end;

  Close;
end;

procedure TfrmNewVault.updateControls;
begin
  btnCreate.Enabled :=
    (edtPath.Directory <> '') and
    (edtVaultName.Text <> '') and
    (edtPassword.Text <> '') and
    (edtRepeatPassword.Text <> '') and
    (Length(edtPassword.Text) = Length(edtRepeatPassword.Text));
end;

procedure TfrmNewVault.edtPasswordChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.edtPathChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.edtRepeatPasswordChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.edtVaultNameChange(Sender: TObject);
begin
  updateControls();
end;

end.
