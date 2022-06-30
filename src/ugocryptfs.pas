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

function init(const vaultName: string; path: string; const pass: string): boolean;
function dumpMasterKey(path: string; const pass: string): TInitRec;
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
  sl: TStringList;

begin
  Result.Completed := False;

  path := path + DirectorySeparator + GOCRYPTFS_CONF;

  try
    sl := TStringList.Create;
    sl.Add('-dumpmasterkey');
    sl.Add(path);
    p := ProcStart(GOCRYPTFS_XRAY_BIN, sl, pass);
  finally
    FreeAndNil(sl);
  end;

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
  sl: TStringList;

begin
  Result := False;

  path := path + DirectorySeparator + vaultName;

  if not mkDir(path) then
    Exit;

  try
    sl := TStringList.Create;
    sl.Add('-init');
    sl.Add(path);
    p := ProcStart(GOCRYPTFS_BIN, sl, pass);
  finally
    FreeAndNil(sl);
  end;

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
  sl: TStringList;
  genMountPoint: string;

begin
  Result.Completed := False;

  genMountPoint := mountpoint + DirectorySeparator + ExtractFileName(cipherdir) + '_' + getRandomName(8);

  if not mkDir(genMountPoint) then
    Exit;

  try
    sl := TStringList.Create;

    if ReadOnly then
      sl.Add('-ro');

    sl.Add(cipherdir);
    sl.Add(genMountPoint);

    p := ProcStart(GOCRYPTFS_BIN, sl, pass);

  finally
    FreeAndNil(sl);
  end;

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
  sl: TStringList;

begin
  try
    sl := TStringList.Create;
    sl.Add('-fsck');
    sl.Add(cipherdir);
    p := ProcStart(GOCRYPTFS_BIN, sl, pass);
  finally
    FreeAndNil(sl);
  end;

  if p.Completed then
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

procedure getVaultInfo(const cipherdir: string);
var
  p: TProcessRec;
  sl: TStringList;

begin
  try
    sl := TStringList.Create;
    sl.Add('-info');
    sl.Add(cipherdir);
    p := ProcStart(GOCRYPTFS_BIN, sl);
  finally
    FreeAndNil(sl);
  end;

  if p.Completed then
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

end.
