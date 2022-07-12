unit uSettingsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Spin;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnSelectMountPoint: TButton;
    btnSave: TButton;
    cbAutorun: TCheckBox;
    edtMountPoint: TEdit;
    gbSettings: TGroupBox;
    lblFontSize: TLabel;
    lblMountPoint: TLabel;
    sddMountPoint: TSelectDirectoryDialog;
    seFontSize: TSpinEdit;
    stMountPointHint: TStaticText;
    procedure btnSaveClick(Sender: TObject);
    procedure btnSelectMountPointClick(Sender: TObject);
    procedure edtMountPointChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  frmSettings: TfrmSettings;

implementation

uses
  uMainForm, uLogForm;

resourcestring
  MOUNTPOINT_HINT = 'During the mount, directories with the storage name will be temporarily created in this directory, for example:';

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.btnSelectMountPointClick(Sender: TObject);
begin
  if sddMountPoint.Execute then
    edtMountPoint.Text := sddMountPoint.FileName;
end;

procedure TfrmSettings.edtMountPointChange(Sender: TObject);
begin
  stMountPointHint.Caption := MOUNTPOINT_HINT + ' ' + edtMountPoint.Text + DirectorySeparator + 'VAULTNAME_XXX';
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  frmMain.config.mountPoint := edtMountPoint.Text;
  frmMain.config.autorunState := cbAutorun.Checked;
  frmMain.config.logFontSize := seFontSize.Value;
  frmLog.synLog.Font.Size := seFontSize.Value;
  Close;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  cbAutorun.Checked := frmMain.config.autorunState;
  edtMountPoint.Text := frmMain.config.mountPoint;
  seFontSize.Value := frmMain.config.logFontSize;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
end;

end.
