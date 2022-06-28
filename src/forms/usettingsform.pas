unit uSettingsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls,
  ButtonPanel, Spin;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnSelectMountPoint: TButton;
    btnpMain: TButtonPanel;
    cbAutorun: TCheckBox;
    edtMountPoint: TEdit;
    gbSettings: TGroupBox;
    lblFontSize: TLabel;
    lblMountPoint: TLabel;
    sddMountPoint: TSelectDirectoryDialog;
    seFontSize: TSpinEdit;
    procedure btnSelectMountPointClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public

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

procedure TfrmSettings.OKButtonClick(Sender: TObject);
begin
  frmMain.config.mountPoint := edtMountPoint.Text;
  frmMain.config.autorunState := cbAutorun.Checked;
  frmMain.config.logFontSize := seFontSize.Value;
  frmMain.synLog.Font.Size := seFontSize.Value;
  Close;
end;

end.
