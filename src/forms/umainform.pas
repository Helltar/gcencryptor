unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FileCtrl, ExtCtrls, LCLIntf, Menus, LCLType, Clipbrd, ComCtrls, Buttons,
  LCLTranslator, DefaultTranslator, ActnList,
  //------------------
  uConfig, uMountList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actHideMenubar: TAction;
    actlMain: TActionList;
    btnMount: TBitBtn;
    btnUmount: TBitBtn;
    btnUmountAll: TBitBtn;
    cbROMount: TCheckBox;
    gbCurrentVault: TGroupBox;
    ilVaultState: TImageList;
    lvVaults: TListView;
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
    pnlMountButton: TPanel;
    sddOpenVault: TSelectDirectoryDialog;
    sp1: TMenuItem;
    sp2: TMenuItem;
    pmMain: TPopupMenu;
    splLeft: TSplitter;
    stVaultPath: TStaticText;
    stMountVaultPath: TStaticText;
    procedure actHideMenubarExecute(Sender: TObject);
    procedure btnMountClick(Sender: TObject);
    procedure btnUmountAllClick(Sender: TObject);
    procedure btnUmountClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvVaultsDblClick(Sender: TObject);
    procedure lvVaultsSelectItem(Sender: TObject; Item: TListItem; Selected: boolean);
    procedure miConfigClick(Sender: TObject);
    procedure miEnglishClick(Sender: TObject);
    procedure miFsckClick(Sender: TObject);
    procedure miCreateNewVaultClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miOpenVaultClick(Sender: TObject);
    procedure miDelFromListClick(Sender: TObject);
    procedure miRussianClick(Sender: TObject);
    procedure miUkrainianClick(Sender: TObject);
    procedure miVaultInfoClick(Sender: TObject);
    procedure pmMainPopup(Sender: TObject);
    procedure sddOpenVaultFolderChange(Sender: TObject);
    procedure stVaultPathClick(Sender: TObject);
    procedure stMountVaultPathClick(Sender: TObject);
  private
    fileList: TStringList;
    mountList: TMountList;
    vaultListConfigFile: string;
    function isItemSelected(): boolean;
    function umountAll(): boolean;
    procedure initControls();
    procedure saveConfig();
    function getSelectedMountPoint(): string;
    function getSelectedVaultPath(): string;
    function isOpenVaultsExists(): boolean;
    function isNotVaultUnlock(const vault: string): boolean;
    procedure showPasswordForm(const title: string);
    procedure hideMenubar();
  public
    config: TConfig;
    vaultPassword: string;
    procedure addVaultToList(const path: string);
    procedure updateControls();
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uUtils, uLogger, ugocryptfs, ugocryptfsFsck,
  uLogForm, uNewVaultForm, uSettingsForm, uPasswordForm,
  uAboutForm;

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

procedure TfrmMain.miConfigClick(Sender: TObject);
begin
  with TfrmSettings.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.miEnglishClick(Sender: TObject);
begin
  SetDefaultLang('en');
  config.lang := 'en';
end;

procedure TfrmMain.miFsckClick(Sender: TObject);
begin
  showPasswordForm(getSelectedVaultPath());

  if not vaultPassword.IsEmpty then
  begin
    fsck(getSelectedVaultPath(), vaultPassword);
    vaultPassword := '';
    frmLog.waitOnThreadFinish();
    updateControls();
  end;
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

procedure TfrmMain.miRussianClick(Sender: TObject);
begin
  SetDefaultLang('ru');
  config.lang := 'ru';
end;

procedure TfrmMain.miUkrainianClick(Sender: TObject);
begin
  SetDefaultLang('uk');
  config.lang := 'uk';
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
  OpenURL(getSelectedVaultPath());
end;

procedure TfrmMain.stMountVaultPathClick(Sender: TObject);
begin
  OpenURL(getSelectedMountPoint());
end;

procedure TfrmMain.updateControls;
var
  i: integer;

begin
  stVaultPath.Visible := False;
  stMountVaultPath.Visible := False;
  cbROMount.Visible := False;

  btnMount.Enabled := False;
  btnUmount.Enabled := False;
  btnUmountAll.Enabled := False;

  miFsck.Enabled := False;
  miVaultInfo.Enabled := False;
  miDelFromList.Enabled := False;

  if not isItemSelected() then
  begin
    gbCurrentVault.Enabled := False;
    Exit;
  end;

  gbCurrentVault.Enabled := True;

  stVaultPath.Caption := StringReplace(getSelectedVaultPath(), GetUserDir, '~' + DirectorySeparator, [rfReplaceAll]);
  stVaultPath.Visible := True;

  stMountVaultPath.Caption := ExtractFileName(getSelectedMountPoint());
  stMountVaultPath.Visible := getSelectedMountPoint() <> '';
  stMountVaultPath.Hint := StringReplace(getSelectedMountPoint(), GetUserDir, '~' + DirectorySeparator, [rfReplaceAll]);

  btnMount.Enabled := isNotVaultUnlock(getSelectedVaultPath());
  cbROMount.Visible := btnMount.Enabled;
  btnUmount.Enabled := not isNotVaultUnlock(getSelectedVaultPath());
  btnUmountAll.Enabled := isOpenVaultsExists();

  miVaultInfo.Enabled := DirectoryExists(getSelectedVaultPath());
  miFsck.Enabled := isFsckThreadStopped and btnMount.Enabled and miVaultInfo.Enabled;
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
  SetDefaultLang(config.lang);

  Height := config.frmHeight;
  Width := config.frmWidth;

  splLeft.Left := config.splLeft;

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

  sddOpenVault.InitialDir := GetUserDir;

  if not config.showMenubar then
    hideMenubar();
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
  begin
    Menu := nil;
    config.showMenubar := False;
  end
  else
  begin
    Menu := mmMain;
    config.showMenubar := True;
  end;
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

function TfrmMain.isItemSelected: boolean;
begin
  Result := lvVaults.ItemIndex >= 0;
end;

procedure TfrmMain.btnMountClick(Sender: TObject);
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

  m := mount(getSelectedVaultPath(), config.mountPoint, vaultPassword, cbROMount.Checked, config.mountPointShortName);
  vaultPassword := '';

  if m.Completed then
  begin
    mountList.add(getSelectedVaultPath(), m.Point);
    Clipboard.AsText := '';
    if config.autorunState then
      OpenURL(m.Point);
  end;

  updateControls;
end;

procedure TfrmMain.actHideMenubarExecute(Sender: TObject);
begin
  hideMenubar();
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

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;

  if isOpenVaultsExists() then
    case MessageDlg(CAPTION_WARNING, LOCK_ALL_AND_CLOSE, mtConfirmation, [mbYes, mbCancel], 0) of
      mrYes:
        if not umountAll() then
          Exit;

      mrCancel: Exit;
    end;

  CanClose := True;
end;

end.
