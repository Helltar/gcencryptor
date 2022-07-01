unit ugocryptfs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TInitRec = record
    Completed: boolean;
    Output: string;
  end;

  TMountRec = record
    Completed: boolean;
    Point: string;
  end;

function dumpMasterKey(path: string; const pass: string): TInitRec;
function init(const vaultName: string; path: string; const pass: string): boolean;
function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean = False): TMountRec;
procedure fsck(const cipherdir, pass: string);
procedure getVaultInfo(const cipherdir: string);

implementation

uses
  uUtils, uLogger;

resourcestring
  SUCCESSFULLY_MOUNTED = 'Filesystem mounted and ready';
  CREATED_SUCCESSFULLY = 'The gocryptfs filesystem has been created successfully';

const
  GOCRYPTFS_BIN = 'gocryptfs';
  GOCRYPTFS_XRAY_BIN = 'gocryptfs-xray';
  GOCRYPTFS_CONF = 'gocryptfs.conf';

function dumpMasterKey(path: string; const pass: string): TInitRec;
var
  p: TProcessRec;

begin
  Result.Completed := False;

  path := path + DirectorySeparator + GOCRYPTFS_CONF;

  p := procStart(GOCRYPTFS_XRAY_BIN, '-dumpmasterkey' + LineEnding + path, pass);

  if p.Completed and (p.ExitStatus = 0) then
  begin
    Result.Completed := True;
    Result.Output := p.Output;
  end
  else
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

function init(const vaultName: string; path: string; const pass: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

  path := path + DirectorySeparator + vaultName;

  if not mkDir(path) then
    Exit;

  p := procStart(GOCRYPTFS_BIN, '-init' + LineEnding + path, pass);

  if p.Completed and (p.ExitStatus = 0) then
  begin
    Result := True;
    addLog(CREATED_SUCCESSFULLY, path);
  end
  else
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean): TMountRec;
var
  p: TProcessRec;
  genMountPoint: string;
  cmd: string = '';

begin
  Result.Completed := False;

  genMountPoint := mountpoint + DirectorySeparator + ExtractFileName(cipherdir) + '_' + getRandomName(8);

  if not mkDir(genMountPoint) then
    Exit;

  if ReadOnly then
    cmd := '-ro' + LineEnding;

  cmd := cmd + cipherdir + LineEnding + genMountPoint;

  p := procStart(GOCRYPTFS_BIN, cmd, pass, True);

  if p.Completed and (p.ExitStatus = 0) then
  begin
    Result.Completed := True;
    Result.Point := genMountPoint;
    addLog(SUCCESSFULLY_MOUNTED, genMountPoint);
  end
  else
  begin
    deldir(genMountPoint);
    addGoCryptFsLog(p.Output, p.ExitStatus);
  end;
end;

procedure fsck(const cipherdir, pass: string);
var
  p: TProcessRec;

begin
  p := procStart(GOCRYPTFS_BIN, '-fsck' + LineEnding + cipherdir, pass);

  if p.Completed then
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

procedure getVaultInfo(const cipherdir: string);
var
  p: TProcessRec;

begin
  p := procStart(GOCRYPTFS_BIN, '-info' + LineEnding + cipherdir);

  if p.Completed then
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

end.
