unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileCtrl,
  ExtCtrls, SynEdit, LCLIntf, Menus, LCLType, synhighlighterunixshellscript,
  Clipbrd, ComCtrls,
  { ---------------- }
  uConfig, uMountList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnUmount: TButton;
    btnMount: TButton;
    btnUmountAll: TButton;
    btnClearLog: TButton;
    btnFsck: TButton;
    cbROMount: TCheckBox;
    edtPassword: TEdit;
    gbCurrentVault: TGroupBox;
    ilVaultState: TImageList;
    lvVaults: TListView;
    miCreateNewVault: TMenuItem;
    miVaultInfo: TMenuItem;
    mmMain: TMainMenu;
    miSettings: TMenuItem;
    miAbout: TMenuItem;
    miVault: TMenuItem;
    miOpenVault: TMenuItem;
    miDelFromList: TMenuItem;
    pnlMountButton: TPanel;
    sddOpenVault: TSelectDirectoryDialog;
    sp1: TMenuItem;
    sp2: TMenuItem;
    pmMain: TPopupMenu;
    splLeft: TSplitter;
    stVaultPath: TStaticText;
    stMountVaultPath: TStaticText;
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    procedure btnFsckClick(Sender: TObject);
    procedure btnMountClick(Sender: TObject);
    procedure btnUmountAllClick(Sender: TObject);
    procedure btnUmountClick(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure edtPasswordChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvVaultsDblClick(Sender: TObject);
    procedure lvVaultsSelectItem(Sender: TObject; Item: TListItem; Selected: boolean);
    procedure miCreateNewVaultClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miOpenVaultClick(Sender: TObject);
    procedure miDelFromListClick(Sender: TObject);
    procedure miVaultInfoClick(Sender: TObject);
    procedure pmMainPopup(Sender: TObject);
    procedure sddOpenVaultFolderChange(Sender: TObject);
    procedure stVaultPathClick(Sender: TObject);
    procedure stMountVaultPathClick(Sender: TObject);
    procedure synLogEnter(Sender: TObject);
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
    procedure addSynLog(const msg: string; const err: boolean = False);
    procedure addVaultToList(const path: string);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ugocryptfs, uUtils, uLogger,
  uNewVaultForm, uSettingsForm, uAboutForm;

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
      begin
        lvVaults.AddItem(ExtractFileName(fileList[i]), nil);
        lvVaults.Items[i].ImageIndex := 0; // lock.icon
      end;
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

procedure TfrmMain.lvVaultsDblClick(Sender: TObject);
begin
  if isItemSelected() then
    OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.lvVaultsSelectItem(Sender: TObject; Item: TListItem; Selected: boolean);
begin
  updateControls;
end;

procedure TfrmMain.miCreateNewVaultClick(Sender: TObject);
begin
  with TfrmNewVault.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
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
  if sddOpenVault.Execute then
    addVaultToList(sddOpenVault.FileName);
end;

procedure TfrmMain.miDelFromListClick(Sender: TObject);
var
  index: integer;

begin
  index := lvVaults.ItemIndex;

  mountList.del(getSelectedVaultPath());
  fileList.Delete(index);
  if lvVaults.Items[index].Selected then
    lvVaults.Items.Delete(index);

  // select previous
  if index >= 1 then
  begin
    Dec(index);
    lvVaults.ItemIndex := index;
  end
  else
  if lvVaults.Items.Count >= 1 then
    lvVaults.ItemIndex := 0;

  if not isItemSelected() then
    stVaultPath.Caption := '';

  updateControls();
end;

procedure TfrmMain.miVaultInfoClick(Sender: TObject);
begin
  getVaultInfo(getSelectedVaultPath());
end;

procedure TfrmMain.pmMainPopup(Sender: TObject);
begin
  updateControls;
end;

procedure TfrmMain.sddOpenVaultFolderChange(Sender: TObject);
begin
  stVaultPath.Caption := sddOpenVault.FileName;
end;

procedure TfrmMain.stVaultPathClick(Sender: TObject);
begin
  OpenURL(stVaultPath.Caption);
end;

procedure TfrmMain.stMountVaultPathClick(Sender: TObject);
begin
  OpenURL(stMountVaultPath.Caption);
end;

procedure TfrmMain.synLogEnter(Sender: TObject);
begin
  synLog.LineHighlightColor.Foreground := clBtnText;
  synLog.LineHighlightColor.Background := clScrollBar;
end;

procedure TfrmMain.updateControls;
var
  selectedVaultDir: string;
  i: integer;

begin
  gbCurrentVault.Enabled := False;

  stVaultPath.Visible := False;
  stMountVaultPath.Visible := False;

  miVaultInfo.Enabled := False;
  miDelFromList.Enabled := False;

  if not isItemSelected() then
    Exit;

  selectedVaultDir := fileList[lvVaults.ItemIndex];

  gbCurrentVault.Enabled := True;

  stVaultPath.Caption := selectedVaultDir;
  stVaultPath.Visible := True;
  stMountVaultPath.Caption := getSelectedMountPoint();
  stMountVaultPath.Visible := getSelectedMountPoint() <> '';

  btnMount.Enabled := isNotVaultUnlock(selectedVaultDir) and isNotEdtEmpty();
  btnFsck.Enabled := isNotEdtEmpty();
  btnUmount.Enabled := not isNotVaultUnlock(selectedVaultDir);
  btnUmountAll.Enabled := isOpenVaultsExists();

  miVaultInfo.Enabled := DirectoryExists(stVaultPath.Caption);
  miDelFromList.Enabled := not btnUmount.Enabled;

  // update icons
  for i := 0 to lvVaults.Items.Count - 1 do
    if isNotVaultUnlock(fileList[i]) then
      lvVaults.Items[i].ImageIndex := 0 // lock.icon
    else
      lvVaults.Items[i].ImageIndex := 1; // unlock.icon
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

  if lvVaults.Items.Count > 0 then
    if lvVaults.Items.Count > config.latestVaultIndex then
      lvVaults.ItemIndex := config.latestVaultIndex;
end;

procedure TfrmMain.saveConfig;
begin
  config.frmHeight := Height;
  config.frmWidth := Width;
  config.frmLeft := Left;
  config.frmTop := Top;
  config.splLeft := splLeft.Left;
  config.latestVaultIndex := lvVaults.ItemIndex;
end;

function TfrmMain.getSelectedMountPoint: string;
begin
  Result := mountList.getMountPoint(fileList[lvVaults.ItemIndex]);
end;

function TfrmMain.getSelectedVaultPath: string;
begin
  Result := fileList[lvVaults.ItemIndex];
end;

function TfrmMain.isOpenVaultsExists: boolean;
begin
  Result := mountList.isListNotEmpty();
end;

function TfrmMain.isNotVaultUnlock(const vault: string): boolean;
begin
  Result := mountList.getMountPoint(vault) = '';
end;

procedure TfrmMain.addSynLog(const msg: string; const err: boolean);
var
  i: integer;
  s: TStringList;

begin
  s := TStringList.Create;
  s.Text := msg;
  s.Delimiter := LineEnding;

  synLog.Lines.Add(s[0]);

  // 'wordwrap'
  for i := 1 to s.Count - 1 do
    synLog.Lines.Add('  - ' + s[i]);

  synLog.Lines.Add(LineEnding);

  if not err then
  begin
    synLog.LineHighlightColor.Foreground := clBlack;
    synLog.LineHighlightColor.Background := $98FB98; // PaleGreen
  end
  else
  begin
    synLog.LineHighlightColor.Foreground := clWhite;
    synLog.LineHighlightColor.Background := clRed;
  end;

  // scroll down
  synLog.CaretY := synLog.Lines.Count;
  synLog.CaretY := synLog.Lines.Count - s.Count;

  FreeAndNil(s);
end;

procedure TfrmMain.addVaultToList(const path: string);
begin
  if fileList.Count > 0 then
    if fileList.IndexOf(path) <> -1 then
    begin
      lvVaults.ItemIndex := fileList.IndexOf(path);
      Exit;
    end;

  lvVaults.AddItem(ExtractFileName(path), nil);
  fileList.Add(path);
  lvVaults.ItemIndex := fileList.Count - 1;

  updateControls();
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
  Result := (stVaultPath.Caption <> '') and (edtPassword.Text <> '');
end;

function TfrmMain.isItemSelected: boolean;
begin
  Result := lvVaults.ItemIndex >= 0;
end;

procedure TfrmMain.edtPasswordChange(Sender: TObject);
begin
  updateControls;
end;

procedure TfrmMain.btnMountClick(Sender: TObject);
var
  m: TMountRec;

begin
  if not dirExists(stVaultPath.Caption) then
    Exit;

  if not DirectoryExists(config.mountPoint) then
    if not mkDir(config.mountPoint) then
      Exit;

  m := mount(stVaultPath.Caption, config.mountPoint, edtPassword.Text, cbROMount.Checked);

  if m.Completed then
  begin
    mountList.add(stVaultPath.Caption, m.Point);

    edtPassword.Clear;
    Clipboard.AsText := '';

    if config.autorunState then
      OpenURL(m.Point);
  end;

  updateControls;
end;

procedure TfrmMain.btnFsckClick(Sender: TObject);
begin
  fsck(getSelectedVaultPath(), edtPassword.Text);
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

procedure TfrmMain.btnClearLogClick(Sender: TObject);
begin
  synLog.Clear;
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
