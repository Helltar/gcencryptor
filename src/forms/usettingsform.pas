unit uSettingsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Spin, LCLType, Controls;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnCreateDesktopEntry: TButton;
    btnSelectMountPoint: TButton;
    btnSave: TButton;
    cbAutorun: TCheckBox;
    cbTray: TCheckBox;
    cbLongNames: TCheckBox;
    edtMountPoint: TEdit;
    gbMain: TGroupBox;
    lblMountDirectory: TLabel;
    lblFontSize: TLabel;
    sddMountPoint: TSelectDirectoryDialog;
    seFontSize: TSpinEdit;
    stMountPointHint: TStaticText;
    procedure btnCreateDesktopEntryClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSelectMountPointClick(Sender: TObject);
    procedure edtMountPointChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  end;

implementation

uses
  uMainForm, uConsts, uUtils;

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.btnSelectMountPointClick(Sender: TObject);
begin
  if sddMountPoint.Execute then
    edtMountPoint.Text := sddMountPoint.FileName;
end;

procedure TfrmSettings.edtMountPointChange(Sender: TObject);
begin
  stMountPointHint.Caption := RS_MOUNTPOINT_HINT + ' ' + replaceHomeSymbol(edtMountPoint.Text + DirectorySeparator + 'VAULTNAME_6F9619FF');
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  frmMain.config.autorunState := cbAutorun.Checked;
  frmMain.config.logFontSize := seFontSize.Value;
  frmMain.config.mountPoint := edtMountPoint.Text;
  frmMain.config.mountPointLongName := cbLongNames.Checked;
  frmMain.config.showTrayIcon := cbTray.Checked;
  frmMain.showTrayIcon := cbTray.Checked;
  frmMain.trayIcon.Visible := cbTray.Checked;

  Close;
end;

procedure TfrmSettings.btnCreateDesktopEntryClick(Sender: TObject);
begin
  if createDesktopEntry() then
    ShowMessage('Shortcut successfully created');
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  cbAutorun.Checked := frmMain.config.autorunState;
  cbLongNames.Checked := frmMain.config.mountPointLongName;
  cbTray.Checked := frmMain.config.showTrayIcon;
  cbTray.Visible := getCurrentDesktop() = KDE_DESKTOP;
  edtMountPoint.Text := frmMain.config.mountPoint;
  sddMountPoint.InitialDir := GetUserDir;
  seFontSize.Value := frmMain.config.logFontSize;
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
