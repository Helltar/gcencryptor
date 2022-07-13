unit ugocryptfs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls;

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
function init(const path: string; const pass: string): boolean;
function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean = False; const shortName: boolean = False): TMountRec;
procedure getVaultInfo(const cipherdir: string);
procedure fsck(const ACipherdir, pass: string);

const
  GOCRYPTFS_BIN = 'gocryptfs';

implementation

uses
  uLogger, uUtils, ugocryptfsFsck;

const
  GOCRYPTFS_XRAY_BIN = 'gocryptfs-xray';
  GOCRYPTFS_CONF = 'gocryptfs.conf';

resourcestring
  SUCCESSFULLY_MOUNTED = 'Filesystem mounted and ready';
  CREATED_SUCCESSFULLY = 'The gocryptfs filesystem has been created successfully';

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

function init(const path: string; const pass: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

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

function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean; const shortName: boolean): TMountRec;
var
  p: TProcessRec;
  guid, genMountPoint: string;
  cmd: string = '';
  shortGuid: TStringArray;

begin
  Result.Completed := False;

  guid := TGUID.NewGuid.ToString(True);

  if shortName then
  begin
    shortGuid := guid.Split('-');
    guid := shortGuid[0];
  end;

  genMountPoint := mountpoint + DirectorySeparator + ExtractFileName(cipherdir) + '_' + guid;

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

procedure fsck(const ACipherdir, pass: string);
begin
  with TFsckThread.Create(True) do
  begin
    Cipherdir := ACipherdir;
    Password := pass;
    Start;
  end;
end;

procedure getVaultInfo(const cipherdir: string);
var
  p: TProcessRec;

begin
  p := procStart(GOCRYPTFS_BIN, '-info' + LineEnding + cipherdir);

  if p.Completed then
    addGoCryptFsLog(p.Output, p.ExitStatus, True);
end;

end.
