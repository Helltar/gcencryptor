unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LCLIntf, Menus, LCLType, Clipbrd, ComCtrls, Buttons,
  ActnList, LCLTranslator,
  //------------------
  uConfig, uMountList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actHideMenubar: TAction;
    actCreateVault: TAction;
    actConfigure: TAction;
    actFsck: TAction;
    actReadOnlyMount: TAction;
    actOpenMountDir: TAction;
    actOpenVaultDir: TAction;
    actLock: TAction;
    actUnlock: TAction;
    Action3: TAction;
    Action4: TAction;
    actlVault: TActionList;
    actVaultInfo: TAction;
    actDelFromList: TAction;
    actlPopupMenu: TActionList;
    actLockAll: TAction;
    actOpenVault: TAction;
    actlMainMenu: TActionList;
    bbtnUnlock: TBitBtn;
    bbtnLock: TBitBtn;
    bbtnLockAll: TBitBtn;
    cbReadOnlyMount: TCheckBox;
    gbCurrentVault: TGroupBox;
    ilVaultState: TImageList;
    ilMainmenu: TImageList;
    ilPopupmenu: TImageList;
    lvVaults: TListView;
    miShowFormTray: TMenuItem;
    miLockAllTray: TMenuItem;
    miQuitTray: TMenuItem;
    miOpenMountDir: TMenuItem;
    miOpenVaultDir: TMenuItem;
    miExit: TMenuItem;
    miShowMenubar: TMenuItem;
    miUkrainian: TMenuItem;
    miEnglish: TMenuItem;
    miRussian: TMenuItem;
    miLanguage: TMenuItem;
    miConfig: TMenuItem;
    miFsck: TMenuItem;
    miCreateNewVault: TMenuItem;
    miVaultInfo: TMenuItem;
    mmMain: TMainMenu;
    miSettings: TMenuItem;
    miAbout: TMenuItem;
    miVault: TMenuItem;
    miOpenVault: TMenuItem;
    miDelFromList: TMenuItem;
    pnlButtons: TPanel;
    pmTray: TPopupMenu;
    sddOpenVault: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    sp1: TMenuItem;
    sp2: TMenuItem;
    pmMain: TPopupMenu;
    splLeft: TSplitter;
    stVaultPath: TStaticText;
    tmCheckLockFile: TTimer;
    trayIcon: TTrayIcon;
    procedure actConfigureExecute(Sender: TObject);
    procedure actCreateVaultExecute(Sender: TObject);
    procedure actDelFromListExecute(Sender: TObject);
    procedure actDelFromListUpdate(Sender: TObject);
    procedure actFsckUpdate(Sender: TObject);
    procedure actHideMenubarExecute(Sender: TObject);
    procedure actFsckExecute(Sender: TObject);
    procedure actOpenMountDirExecute(Sender: TObject);
    procedure actOpenMountDirUpdate(Sender: TObject);
    procedure actOpenVaultDirExecute(Sender: TObject);
    procedure actOpenVaultDirUpdate(Sender: TObject);
    procedure actLockUpdate(Sender: TObject);
    procedure actUnlockExecute(Sender: TObject);
    procedure actUnlockUpdate(Sender: TObject);
    procedure actVaultInfoExecute(Sender: TObject);
    procedure actLockAllExecute(Sender: TObject);
    procedure actLockAllUpdate(Sender: TObject);
    procedure actLockExecute(Sender: TObject);
    procedure actOpenVaultExecute(Sender: TObject);
    procedure actVaultInfoUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormShow(Sender: TObject);
    procedure lvVaultsDblClick(Sender: TObject);
    procedure lvVaultsSelectItem(Sender: TObject; Item: TListItem; Selected: boolean);
    procedure miShowFormTrayClick(Sender: TObject);
    procedure miQuitTrayClick(Sender: TObject);
    procedure miEnglishClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miRussianClick(Sender: TObject);
    procedure miUkrainianClick(Sender: TObject);
    procedure stVaultPathClick(Sender: TObject);
    procedure tmCheckLockFileTimer(Sender: TObject);
    procedure trayIconClick(Sender: TObject);
  private
    fileList: TStringList;
    mountList: TMountList;
    vaultListConfigFile: string;
    function getSelectedMountPoint(): string;
    function getSelectedVaultPath(): string;
    function isItemSelected(): boolean;
    function isNotVaultUnlock(const vault: string): boolean;
    function isSelectedVaultPathExists(): boolean;
    function isSelectedVaultUnlock(): boolean;
    function isUnlockedVaultsExists(): boolean;
    function umountAll(): boolean;
    procedure hideMenubar();
    procedure initControls();
    procedure initVaultList();
    procedure saveConfig();
    procedure showPasswordForm(const title: string);
    procedure updateControls();
    procedure updateVaultListIcons();
    procedure showHideForm();
    procedure setLang(const langCode: string);
  public
    config: TConfig;
    primaryLockFilename: string;
    vaultPassword: string;
    showTrayIcon: boolean;
    procedure addVaultToList(const path: string);
    procedure addSynLog(const msg: string; const err: boolean = False; const showForm: boolean = False);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uUtils, uLogger, ugocryptfs, ugocryptfsFsck,
  uLogForm, uNewVaultForm, uSettingsForm, uConsts,
  uPasswordForm, uAboutForm, uCloseQueryForm;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  config := TConfig.Create(GetAppConfigDir(False) + MAIN_CONF_FILENAME);
  fileList := TStringList.Create;
  mountList := TMountList.Create;

  vaultListConfigFile := GetAppConfigDir(False) + VAULTLIST_CONF_FILENAME;
  showTrayIcon := config.showTrayIcon;

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
  updateControls();
end;

procedure TfrmMain.miShowFormTrayClick(Sender: TObject);
begin
  showHideForm();
end;

procedure TfrmMain.miQuitTrayClick(Sender: TObject);
begin
  Show;
  showTrayIcon := False;
  Close;
end;

procedure TfrmMain.miEnglishClick(Sender: TObject);
begin
  setLang('en');
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

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  showTrayIcon := False;
  Close;
end;

procedure TfrmMain.miRussianClick(Sender: TObject);
begin
  setLang('ru');
end;

procedure TfrmMain.miUkrainianClick(Sender: TObject);
begin
  setLang('uk');
end;

procedure TfrmMain.stVaultPathClick(Sender: TObject);
begin
  if getSelectedMountPoint().IsEmpty then
    if isSelectedVaultPathExists() then
      OpenURL(getSelectedVaultPath())
    else
      updateControls()
  else
    OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.tmCheckLockFileTimer(Sender: TObject);
var
  secondaryLockFilename: string;

begin
  secondaryLockFilename := primaryLockFilename + '1';

  if FileExists(secondaryLockFilename) then
  begin
    DeleteFile(secondaryLockFilename);
    Show;
  end;
end;

procedure TfrmMain.trayIconClick(Sender: TObject);
begin
  showHideForm();
end;

procedure TfrmMain.initControls;
begin
  SetDefaultLang(config.lang);

  Caption := APP_NAME;
  Height := config.frmHeight;
  Width := config.frmWidth;

  if (config.frmLeft + config.frmTop) > 0 then
  begin
    Left := config.frmLeft;
    Top := config.frmTop;
  end
  else
    Position := poScreenCenter;

  if not config.showMenubar then
    hideMenubar();

  splLeft.Left := config.splLeft;
  sddOpenVault.InitialDir := GetUserDir;

  initVaultList();
end;

procedure TfrmMain.initVaultList;
var
  path: string;

begin
  if not FileExists(vaultListConfigFile) then
    Exit;

  try
    fileList.Sorted := True; // sort and rm duplicates if exists
    fileList.LoadFromFile(vaultListConfigFile);
    fileList.Sorted := False; // false because vault list don't sorted

    for path in fileList do
      lvVaults.AddItem(ExtractFileName(path), nil);
  except
    addErrLog(RS_ERROR_LOAD_CONFIG, vaultListConfigFile);
  end;

  if lvVaults.Items.Count > config.latestVaultIndex then
    lvVaults.ItemIndex := config.latestVaultIndex;

  updateVaultListIcons();
end;

function TfrmMain.getSelectedMountPoint: string;
begin
  if isItemSelected() then
    Result := mountList.getMountPoint(fileList[lvVaults.ItemIndex])
  else
    Result := '';
end;

function TfrmMain.getSelectedVaultPath: string;
begin
  if isItemSelected() then
    Result := fileList[lvVaults.ItemIndex]
  else
    Result := '';
end;

function TfrmMain.isUnlockedVaultsExists: boolean;
begin
  Result := mountList.isListNotEmpty();
end;

function TfrmMain.isNotVaultUnlock(const vault: string): boolean;
begin
  Result := mountList.getMountPoint(vault) = '';
end;

function TfrmMain.isSelectedVaultUnlock: boolean;
begin
  Result := not isNotVaultUnlock(getSelectedVaultPath());
end;

procedure TfrmMain.showPasswordForm(const title: string);
begin
  with TfrmPassword.Create(Self) do
    try
      lblVault.Caption := title;
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.hideMenubar;
begin
  if Menu <> nil then
    Menu := nil
  else
    Menu := mmMain;

  config.showMenubar := Menu <> nil;
end;

procedure TfrmMain.addVaultToList(const path: string);
begin
  if fileList.Count > 0 then
    if fileList.IndexOf(path) <> -1 then
    begin
      lvVaults.ItemIndex := fileList.IndexOf(path);
      Exit;
    end;

  fileList.Add(path);
  lvVaults.AddItem(ExtractFileName(path), nil);
  lvVaults.ItemIndex := fileList.Count - 1;
end;

procedure TfrmMain.addSynLog(const msg: string; const err: boolean; const showForm: boolean);
begin
  if Assigned(frmLog) then
  begin
    frmLog.addSynLog(msg, err);
    if showForm then
      frmLog.Show;
  end
  else
    WriteLn(msg);
end;

procedure TfrmMain.updateVaultListIcons;
var
  i: integer;

begin
  for i := 0 to lvVaults.Items.Count - 1 do
    if isNotVaultUnlock(fileList[i]) then
      if DirectoryExists(fileList[i]) then
        lvVaults.Items[i].ImageIndex := 0 // lock
      else
        lvVaults.Items[i].ImageIndex := 2 // not found
    else
      lvVaults.Items[i].ImageIndex := 1; // unlock
end;

procedure TfrmMain.showHideForm;
begin
  if Visible then
    Hide
  else
    Show;
end;

procedure TfrmMain.setLang(const langCode: string);
begin
  SetDefaultLang(langCode);
  config.lang := langCode;
end;

procedure TfrmMain.updateControls;
begin
  stVaultPath.Font.Color := clBtnText;
  stVaultPath.Enabled := False;
  cbReadOnlyMount.Visible := False;

  if not isItemSelected() then
  begin
    gbCurrentVault.Caption := RS_GB_VAULT_CAPTION;
    stVaultPath.Caption := '';
    stVaultPath.Hint := '';
    Exit;
  end;

  if isSelectedVaultPathExists() then
  begin
    stVaultPath.Enabled := True;
    gbCurrentVault.Caption := getDirSize(getSelectedVaultPath());

    if getSelectedMountPoint().IsEmpty then
    begin
      cbReadOnlyMount.Visible := True;
      stVaultPath.Caption := replaceHomeSymbol(getSelectedVaultPath());
      stVaultPath.Hint := RS_VAULTPATH_HINT;
    end
    else
    begin
      stVaultPath.Font.Color := clGreen;
      stVaultPath.Caption := ExtractFileName(getSelectedMountPoint());
      stVaultPath.Hint := replaceHomeSymbol(getSelectedMountPoint()) + ' ...';
    end;
  end
  else
  begin
    gbCurrentVault.Caption := '404';
    stVaultPath.Caption := RS_DIRECTORY_NOT_EXISTS;
    stVaultPath.Hint := '';
  end;

  updateVaultListIcons();
end;

function TfrmMain.isSelectedVaultPathExists: boolean;
begin
  Result := DirectoryExists(getSelectedVaultPath());
end;

function TfrmMain.umountAll: boolean;
var
  i: integer;
  isFail: boolean = False;

begin
  for i := mountList.getSize() downto 0 do
    if umount(mountList.getMountPoint(i)) then
      mountList.del(i)
    else
      isFail := True;

  Result := not isFail;
  updateControls();
end;

function TfrmMain.isItemSelected: boolean;
begin
  Result := (lvVaults.Items.Count > 0) and (lvVaults.ItemIndex >= 0);
end;

procedure TfrmMain.actHideMenubarExecute(Sender: TObject);
begin
  hideMenubar();
end;

procedure TfrmMain.actFsckExecute(Sender: TObject);
begin
  showPasswordForm(getSelectedVaultPath());

  if not vaultPassword.IsEmpty then
  begin
    frmLog.waitOnThreadFinish();
    fsck(getSelectedVaultPath(), vaultPassword);
    vaultPassword := '';
  end;
end;

procedure TfrmMain.actOpenMountDirExecute(Sender: TObject);
begin
  OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.actOpenMountDirUpdate(Sender: TObject);
begin
  actOpenMountDir.Enabled := isItemSelected() and isSelectedVaultUnlock() and isSelectedVaultPathExists();
end;

procedure TfrmMain.actOpenVaultDirExecute(Sender: TObject);
begin
  OpenURL(getSelectedVaultPath());
end;

procedure TfrmMain.actOpenVaultDirUpdate(Sender: TObject);
begin
  actOpenVaultDir.Enabled := isItemSelected() and isSelectedVaultPathExists();
end;

procedure TfrmMain.actLockUpdate(Sender: TObject);
begin
  actLock.Enabled := isItemSelected() and isSelectedVaultUnlock();
end;

procedure TfrmMain.actUnlockExecute(Sender: TObject);
var
  m: TMountRec;

begin
  if not dirExists(getSelectedVaultPath()) then
    Exit;

  if not DirectoryExists(config.mountPoint) then
    if not mkDir(config.mountPoint) then
      Exit;

  showPasswordForm(getSelectedVaultPath());

  if vaultPassword.IsEmpty then
    Exit;

  m := mount(getSelectedVaultPath(), config.mountPoint, vaultPassword, cbReadOnlyMount.Checked, config.mountPointLongName);
  vaultPassword := '';

  if m.Completed then
  begin
    mountList.add(getSelectedVaultPath(), m.Point);
    Clipboard.AsText := '';
    updateControls();
    if config.autorunState then
      OpenURL(m.Point);
  end;
end;

procedure TfrmMain.actUnlockUpdate(Sender: TObject);
begin
  actUnlock.Enabled := isItemSelected() and isSelectedVaultPathExists() and not isSelectedVaultUnlock();
end;

procedure TfrmMain.actVaultInfoExecute(Sender: TObject);
begin
  getVaultInfo(getSelectedVaultPath());
end;

procedure TfrmMain.actLockAllExecute(Sender: TObject);
begin
  if umountAll() then
    actLockAll.Enabled := False;
end;

procedure TfrmMain.actLockAllUpdate(Sender: TObject);
begin
  actLockAll.Enabled := isUnlockedVaultsExists();
end;

procedure TfrmMain.actLockExecute(Sender: TObject);
begin
  if umount(getSelectedMountPoint()) then
  begin
    mountList.del(getSelectedVaultPath());
    updateControls();
  end;
end;

procedure TfrmMain.actOpenVaultExecute(Sender: TObject);
begin
  if sddOpenVault.Execute then
    addVaultToList(sddOpenVault.FileName);
end;

procedure TfrmMain.actVaultInfoUpdate(Sender: TObject);
begin
  actVaultInfo.Enabled := isItemSelected() and isSelectedVaultPathExists();
end;

procedure TfrmMain.actFsckUpdate(Sender: TObject);
begin
  actFsck.Enabled := isItemSelected() and not isSelectedVaultUnlock() and isSelectedVaultPathExists() and isFsckThreadStopped;
end;

procedure TfrmMain.actCreateVaultExecute(Sender: TObject);
begin
  with TfrmNewVault.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.actDelFromListExecute(Sender: TObject);
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
end;

procedure TfrmMain.actDelFromListUpdate(Sender: TObject);
begin
  actDelFromList.Enabled := isItemSelected() and not isSelectedVaultUnlock();
end;

procedure TfrmMain.actConfigureExecute(Sender: TObject);
begin
  with TfrmSettings.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.saveConfig;
begin
  with config do
  begin
    frmHeight := Height;
    frmWidth := Width;
    frmLeft := Left;
    frmTop := Top;
    splLeft := Self.splLeft.Left;
    latestVaultIndex := lvVaults.ItemIndex;
  end;
end;

procedure TfrmMain.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  dir: string;

begin
  for dir in FileNames do
    if DirectoryExists(dir) then
      addVaultToList(dir);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  trayIcon.Visible := config.showTrayIcon;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  i: integer;

begin
  CanClose := False;

  if showTrayIcon then
  begin
    showHideForm();
    Exit;
  end;

  showTrayIcon := config.showTrayIcon;

  if isUnlockedVaultsExists() then
    with TfrmCloseQuery.Create(Self) do
      try
        for i := 0 to mountList.getSize() do
          stVaultList.Caption := stVaultList.Caption + LineEnding + mountList.getVaultDir(i);

        ShowModal;

        if CloseQueryResult then
        begin
          if not umountAll() then
            Exit;
        end
        else
        begin
          Exit;
        end;
      finally
        Free;
      end;

  if not isFsckThreadStopped then
  begin
    frmLog.Show;
    Exit;
  end;

  CanClose := True;
end;

end.
