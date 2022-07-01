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
    procedure btnSaveClick(Sender: TObject);
    procedure btnSelectMountPointClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  frmSettings: TfrmSettings;

implementation

uses
  uMainForm;

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.btnSelectMountPointClick(Sender: TObject);
begin
  if sddMountPoint.Execute then
    edtMountPoint.Text := sddMountPoint.FileName;
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  frmMain.config.mountPoint := edtMountPoint.Text;
  frmMain.config.autorunState := cbAutorun.Checked;
  frmMain.config.logFontSize := seFontSize.Value;
  frmMain.synLog.Font.Size := seFontSize.Value;
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
  Constraints.MinWidth := Width;
end;

end.
