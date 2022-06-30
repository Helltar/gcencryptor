unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileCtrl,
  ExtCtrls, SynEdit, LCLIntf, Menus, LCLType, synhighlighterunixshellscript,
  { ---------------- }
  uConfig, uMountList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnUmount: TButton;
    btnMount: TButton;
    btnUmountAll: TButton;
    cbROMount: TCheckBox;
    edtPassword: TEdit;
    edtCurrentVaultDir: TEdit;
    flbVaultList: TFileListBox;
    gbCurrentVault: TGroupBox;
    miVaultInfo: TMenuItem;
    miFsck: TMenuItem;
    mmMain: TMainMenu;
    miSettings: TMenuItem;
    miAbout: TMenuItem;
    miVault: TMenuItem;
    miOpenVault: TMenuItem;
    miOpenVaultDir: TMenuItem;
    miDelFromList: TMenuItem;
    miOpenCryptoDir: TMenuItem;
    pnlMountButton: TPanel;
    sddNewVault: TSelectDirectoryDialog;
    sp1: TMenuItem;
    sp2: TMenuItem;
    pmMain: TPopupMenu;
    splLeft: TSplitter;
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    procedure btnMountClick(Sender: TObject);
    procedure btnUmountAllClick(Sender: TObject);
    procedure btnUmountClick(Sender: TObject);
    procedure edtNewVaultDirChange(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
    procedure flbVaultListDblClick(Sender: TObject);
    procedure flbVaultListSelectionChange(Sender: TObject; User: boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miFsckClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miOpenVaultClick(Sender: TObject);
    procedure miOpenVaultDirClick(Sender: TObject);
    procedure miDelFromListClick(Sender: TObject);
    procedure miOpenCryptoDirClick(Sender: TObject);
    procedure miVaultInfoClick(Sender: TObject);
    procedure pmMainPopup(Sender: TObject);
    procedure sddNewVaultFolderChange(Sender: TObject);
  private
    fileList: TStringList;
    mountList: TMountList;
    vaultListConfigFile: string;
    function isNotEdtEmpty(): boolean;
    function isItemSelected(): boolean;
    function umountAll(): boolean;
    procedure updateControls();
    procedure initControls();
    procedure saveConfig();
    function getSelectedMountPoint(): string;
    function getSelectedVaultPath(): string;
    function isOpenVaultsExists(): boolean;
    function isNotVaultUnlock(const vault: string): boolean;
  public
    config: TConfig;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ugocryptfs, uUtils, uLogger,
  uSettingsForm, uAboutForm;

resourcestring
  ERROR_LOAD_CONFIG = 'Error load config';
  CAPTION_WARNING = 'Warning';
  LOCK_ALL_AND_CLOSE = 'Lock all and close?';

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
  configDir, configFile: string;

begin
  configDir := GetAppConfigDir(False);
  configFile := configDir + 'config';
  vaultListConfigFile := configDir + 'vaultlist';

  if not DirectoryExists(configDir) then
    mkDir(configDir);

  config := TConfig.Create(configFile);

  fileList := TStringList.Create;
  mountList := TMountList.Create;

  if FileExists(vaultListConfigFile) then
    try
      fileList.LoadFromFile(vaultListConfigFile);

      for i := 0 to fileList.Count - 1 do
        flbVaultList.AddItem(ExtractFileName(fileList[i]), nil);
    except
      addErrLog(ERROR_LOAD_CONFIG, vaultListConfigFile);
    end;

  initControls();
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  saveConfig();

  FreeAndNil(config);
  FreeAndNil(mountList);

  try
    fileList.SaveToFile(vaultListConfigFile);
  finally
    FreeAndNil(fileList);
  end;
end;

procedure TfrmMain.miFsckClick(Sender: TObject);
begin
  fsck(getSelectedVaultPath(), edtPassword.Text);
end;

procedure TfrmMain.miSettingsClick(Sender: TObject);
begin
  with TfrmSettings.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  with TfrmAbout.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.miOpenVaultClick(Sender: TObject);
begin
  if sddNewVault.Execute then
  begin
    if fileList.Count > 0 then
      if fileList.IndexOf(sddNewVault.FileName) <> -1 then
      begin
        flbVaultList.ItemIndex := fileList.IndexOf(sddNewVault.FileName);
        Exit;
      end;

    flbVaultList.AddItem(ExtractFileName(sddNewVault.FileName), nil);
    fileList.Add(sddNewVault.FileName);
    flbVaultList.ItemIndex := fileList.Count - 1;

    updateControls();
  end;
end;

procedure TfrmMain.miOpenVaultDirClick(Sender: TObject);
begin
  OpenURL(edtCurrentVaultDir.Text);
end;

procedure TfrmMain.miDelFromListClick(Sender: TObject);
var
  index: integer;

begin
  index := flbVaultList.ItemIndex;

  mountList.del(getSelectedVaultPath());
  fileList.Delete(index);
  flbVaultList.DeleteSelected;

  // select previous
  if index >= 1 then
  begin
    Dec(index);
    flbVaultList.ItemIndex := index;
  end
  else
  if flbVaultList.Count >= 1 then
    flbVaultList.ItemIndex := 0;

  if not isItemSelected() then
    edtCurrentVaultDir.Clear;

  updateControls();
end;

procedure TfrmMain.miOpenCryptoDirClick(Sender: TObject);
begin
  OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.miVaultInfoClick(Sender: TObject);
begin
  getVaultInfo(getSelectedVaultPath());
end;

procedure TfrmMain.pmMainPopup(Sender: TObject);
begin
  updateControls;
end;

procedure TfrmMain.sddNewVaultFolderChange(Sender: TObject);
begin
  edtCurrentVaultDir.Text := sddNewVault.FileName;
end;

procedure TfrmMain.updateControls;
var
  selectedVaultDir: string;

begin
  btnMount.Enabled := False;
  btnUmount.Enabled := False;
  btnUmountAll.Enabled := False;

  miOpenVaultDir.Enabled := False;
  miOpenCryptoDir.Enabled := False;
  miFsck.Enabled := False;
  miVaultInfo.Enabled := False;
  miDelFromList.Enabled := False;

  if not isItemSelected() then
  begin
    btnMount.Enabled := isNotEdtEmpty();
    Exit;
  end;

  selectedVaultDir := fileList[flbVaultList.ItemIndex];
  edtCurrentVaultDir.Text := selectedVaultDir;

  btnMount.Enabled := isNotVaultUnlock(selectedVaultDir) and isNotEdtEmpty();
  btnUmount.Enabled := not isNotVaultUnlock(selectedVaultDir);
  btnUmountAll.Enabled := isOpenVaultsExists();

  miOpenVaultDir.Enabled := dirExists(edtCurrentVaultDir.Text) and isItemSelected();
  miOpenCryptoDir.Enabled := btnUmount.Enabled;
  miFsck.Enabled := isNotEdtEmpty();
  miVaultInfo.Enabled := miOpenVaultDir.Enabled;
  miDelFromList.Enabled := not btnUmount.Enabled;
end;

procedure TfrmMain.initControls;
begin
  Constraints.MinHeight := 400;
  Constraints.MinWidth := 600;
  Height := config.frmHeight;
  Width := config.frmWidth;

  splLeft.Left := config.splLeft;
  synLog.Font.Size := config.logFontSize;

  if (config.frmLeft + config.frmTop) > 0 then
  begin
    Left := config.frmLeft;
    Top := config.frmTop;
  end
  else
    Position := poScreenCenter;

  if flbVaultList.Count > 0 then
    if flbVaultList.Count > config.latestVaultIndex then
      flbVaultList.ItemIndex := config.latestVaultIndex;
end;

procedure TfrmMain.saveConfig;
begin
  config.frmHeight := Height;
  config.frmWidth := Width;
  config.frmLeft := Left;
  config.frmTop := Top;
  config.splLeft := splLeft.Left;
  config.latestVaultIndex := flbVaultList.ItemIndex;
end;

function TfrmMain.getSelectedMountPoint: string;
begin
  Result := mountList.getMountPoint(fileList[flbVaultList.ItemIndex]);
end;

function TfrmMain.getSelectedVaultPath: string;
begin
  Result := fileList[flbVaultList.ItemIndex];
end;

function TfrmMain.isOpenVaultsExists: boolean;
begin
  Result := mountList.isListNotEmpty();
end;

function TfrmMain.isNotVaultUnlock(const vault: string): boolean;
begin
  Result := mountList.getMountPoint(vault) = '';
end;

function TfrmMain.umountAll: boolean;
var
  i: integer;

begin
  Result := False;

  for i := mountList.getSize() downto 0 do
    if umount(mountList.getMountPoint(i)) then
      mountList.del(i)
    else
      Exit;

  Result := True;
end;

function TfrmMain.isNotEdtEmpty: boolean;
begin
  Result := (edtCurrentVaultDir.Text <> '') and (edtPassword.Text <> '');
end;

function TfrmMain.isItemSelected: boolean;
begin
  Result := flbVaultList.ItemIndex >= 0;
end;

procedure TfrmMain.edtPasswordChange(Sender: TObject);
begin
  updateControls;
end;

procedure TfrmMain.flbVaultListDblClick(Sender: TObject);
begin
  if isItemSelected() then
    OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.flbVaultListSelectionChange(Sender: TObject; User: boolean);
begin
  updateControls;
end;

procedure TfrmMain.btnMountClick(Sender: TObject);
var
  m: TMountRec;

begin
  if not dirExists(edtCurrentVaultDir.Text) then
    Exit;

  m := mount(edtCurrentVaultDir.Text, config.mountPoint, edtPassword.Text, cbROMount.Checked);

  if m.Completed then
  begin
    mountList.add(edtCurrentVaultDir.Text, m.Point);
    edtPassword.Clear;
    if config.autorunState then
      OpenURL(m.Point);
  end;
end;

procedure TfrmMain.btnUmountAllClick(Sender: TObject);
begin
  umountAll();
  updateControls;
end;

procedure TfrmMain.btnUmountClick(Sender: TObject);
begin
  if umount(getSelectedMountPoint()) then
  begin
    mountList.del(getSelectedVaultPath());
    updateControls;
  end;
end;

procedure TfrmMain.edtNewVaultDirChange(Sender: TObject);
begin
  updateControls;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;

  if isOpenVaultsExists() then
    case MessageDlg(CAPTION_WARNING, LOCK_ALL_AND_CLOSE, mtWarning, [mbYes, mbCancel], 0) of
      mrYes:
        if not umountAll() then
          Exit;

      mrCancel: Exit;
    end;

  CanClose := True;
end;

end.
