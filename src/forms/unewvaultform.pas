unit uNewVaultForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmNewVault }

  TfrmNewVault = class(TForm)
    btnCreate: TButton;
    btnSelectPath: TButton;
    edtPath: TEdit;
    edtVaultName: TEdit;
    edtPassword: TEdit;
    edtRepeatPassword: TEdit;
    sddSelectPath: TSelectDirectoryDialog;
    procedure btnCreateClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
    procedure edtPathChange(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
    procedure edtRepeatPasswordChange(Sender: TObject);
    procedure edtVaultNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure createVault(const path: string);
    procedure updateControls();
  end;

implementation

uses
  ugocryptfs, uMainForm, uMasterKeyForm, uLogger;

resourcestring
  PASSWORDS_DO_NOT_MATCH = 'Passwords do not match';
  DIRECTORY_EXISTS = 'Directory already exists';
  FAILED_TO_RETRIEVE_RECOVERY_KEY =  'Vault was successfully created, but could not retrieve the recovery key';

{$R *.lfm}

{ TfrmNewVault }

procedure TfrmNewVault.FormCreate(Sender: TObject);
begin
  sddSelectPath.InitialDir := GetUserDir;
end;

procedure TfrmNewVault.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
end;

procedure TfrmNewVault.btnCreateClick(Sender: TObject);
begin
  if edtPassword.Text <> edtRepeatPassword.Text then
    ShowMessage(PASSWORDS_DO_NOT_MATCH)
  else
  if DirectoryExists(edtPath.Text) then
    ShowMessage(DIRECTORY_EXISTS + ': ' + edtPath.Text)
  else
    createVault(edtPath.Text);
end;

procedure TfrmNewVault.btnSelectPathClick(Sender: TObject);
begin
  if sddSelectPath.Execute then
  begin
    edtPath.Text := sddSelectPath.FileName;
    edtVaultName.Enabled := True;
    edtVaultName.SetFocus;
  end;
end;

procedure TfrmNewVault.edtPathChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.createVault(const path: string);
var
  xRay: TInitRec;

begin
  edtRepeatPassword.Clear;

  if init(path, edtPassword.Text) then
  begin
    frmMain.addVaultToList(path);

    xRay := dumpMasterKey(path, edtPassword.Text);
    edtPassword.Clear;

    if xRay.Completed then
    begin
      with TfrmMasterKey.Create(Self) do
        try
          edtKey.Text := xRay.Output;
          vaultName := edtVaultName.Text;
          xRay.Output := '';
          ShowModal;
        finally
          Free;
        end;
    end
    else
      addErrLog(FAILED_TO_RETRIEVE_RECOVERY_KEY, path);
  end;

  Close;
end;

procedure TfrmNewVault.updateControls;
begin
  edtPassword.Enabled := edtVaultName.Text <> '';
  edtRepeatPassword.Enabled := (edtPassword.Text <> '') and edtPassword.Enabled;

  btnCreate.Enabled :=
    edtPassword.Enabled and
    edtRepeatPassword.Enabled and
    (edtRepeatPassword.Text <> '') and
    (Length(edtPassword.Text) = Length(edtRepeatPassword.Text));
end;

procedure TfrmNewVault.edtPasswordChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.edtRepeatPasswordChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.edtVaultNameChange(Sender: TObject);
begin
  edtPath.Text := sddSelectPath.FileName + DirectorySeparator + edtVaultName.Text;
  updateControls();
end;

end.
