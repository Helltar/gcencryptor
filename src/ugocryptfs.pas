unit ugocryptfs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMountRec = record
    Completed: boolean;
    Point: string;
  end;

procedure fsck(const cipherdir, pass: string);
procedure getVaultInfo(const cipherdir: string);
function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean = False): TMountRec;

implementation

uses
  uUtils, uLogger;

resourcestring
  SUCCESSFULLY_MOUNTED = 'Filesystem mounted and ready';

const
  GOCRYPTFS_BIN = 'gocryptfs';

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
