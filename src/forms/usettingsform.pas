unit uSettingsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Spin, LCLType, Controls;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnSelectMountPoint: TButton;
    btnSave: TButton;
    cbAutorun: TCheckBox;
    cbTray: TCheckBox;
    cbShortNames: TCheckBox;
    edtMountPoint: TEdit;
    gbMain: TGroupBox;
    lblMountDirectory: TLabel;
    lblFontSize: TLabel;
    sddMountPoint: TSelectDirectoryDialog;
    seFontSize: TSpinEdit;
    stMountPointHint: TStaticText;
    procedure btnSaveClick(Sender: TObject);
    procedure btnSelectMountPointClick(Sender: TObject);
    procedure edtMountPointChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  end;

implementation

uses
  uMainForm, uConsts;

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.btnSelectMountPointClick(Sender: TObject);
begin
  if sddMountPoint.Execute then
    edtMountPoint.Text := sddMountPoint.FileName;
end;

procedure TfrmSettings.edtMountPointChange(Sender: TObject);
begin
  stMountPointHint.Caption := RS_MOUNTPOINT_HINT + ' ' + edtMountPoint.Text + DirectorySeparator + 'VAULTNAME_GUID';
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  frmMain.config.mountPoint := edtMountPoint.Text;
  frmMain.config.mountPointShortName := cbShortNames.Checked;
  frmMain.config.autorunState := cbAutorun.Checked;
  frmMain.config.logFontSize := seFontSize.Value;
  frmMain.config.showTrayIcon := cbTray.Checked;
  frmMain.showTrayIcon := cbTray.Checked;
  frmMain.trayIcon.Visible := cbTray.Checked;
  Close;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  cbAutorun.Checked := frmMain.config.autorunState;
  edtMountPoint.Text := frmMain.config.mountPoint;
  cbShortNames.Checked := frmMain.config.mountPointShortName;
  seFontSize.Value := frmMain.config.logFontSize;
  cbTray.Checked := frmMain.config.showTrayIcon;
  sddMountPoint.InitialDir := GetUserDir;
end;

procedure TfrmSettings.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
end;

end.
