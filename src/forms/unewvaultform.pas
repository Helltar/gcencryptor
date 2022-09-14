unit uNewVaultForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType,
  ExtCtrls, Spin;

type

  { TfrmNewVault }

  TfrmNewVault = class(TForm)
    btnCreate: TButton;
    btnSelectPath: TButton;
    cbAdvancedSettings: TCheckBox;
    cbPlainTextNames: TCheckBox;
    edtPath: TEdit;
    edtVaultName: TEdit;
    edtPassword: TEdit;
    edtRepeatPassword: TEdit;
    lblLongNamesMax: TLabel;
    pnlAdvancedSettings: TPanel;
    sddSelectPath: TSelectDirectoryDialog;
    seLongNamesMax: TSpinEdit;
    procedure btnCreateClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
    procedure cbAdvancedSettingsChange(Sender: TObject);
    procedure edtPathChange(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
    procedure edtRepeatPasswordChange(Sender: TObject);
    procedure edtVaultNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    procedure createVault(const path: string);
    procedure updateControls();
  end;

implementation

uses
  ugocryptfs, uMainForm, uMasterKeyForm, uLogger, uConsts;

{$R *.lfm}

{ TfrmNewVault }

procedure TfrmNewVault.FormCreate(Sender: TObject);
begin
  sddSelectPath.InitialDir := GetUserDir;

  if longNameMaxFlagAvailable() then
    seLongNamesMax.Enabled := True
  else
    lblLongNamesMax.Hint := RS_LONGNAMEMAXFLAG_AVAILABLE;

  seLongNamesMax.Hint := lblLongNamesMax.Hint;
end;

procedure TfrmNewVault.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
end;

procedure TfrmNewVault.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
end;

procedure TfrmNewVault.btnCreateClick(Sender: TObject);
begin
  if edtPassword.Text <> edtRepeatPassword.Text then
    ShowMessage(RS_PASSWORDS_DO_NOT_MATCH)
  else
  if DirectoryExists(edtPath.Text) then
    ShowMessage(RS_DIRECTORY_EXISTS + ': ' + edtPath.Text)
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

procedure TfrmNewVault.cbAdvancedSettingsChange(Sender: TObject);
begin
  if cbAdvancedSettings.Checked then
    pnlAdvancedSettings.Visible := True
  else
    pnlAdvancedSettings.Visible := False;
end;

procedure TfrmNewVault.edtPathChange(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmNewVault.createVault(const path: string);
var
  xRay: TInitRec;
  longNamesMaxValue: integer = -1;
  plainTextNames: boolean = False;

begin
  edtRepeatPassword.Clear;

  if cbAdvancedSettings.Checked then
  begin
    plainTextNames := cbPlainTextNames.Checked;

    if seLongNamesMax.Enabled then
      longNamesMaxValue := seLongNamesMax.Value;
  end;

  if init(path, edtPassword.Text, longNamesMaxValue, plainTextNames) then
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
      addErrLog(RS_FAILED_TO_RETRIEVE_RECOVERY_KEY, path);
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
