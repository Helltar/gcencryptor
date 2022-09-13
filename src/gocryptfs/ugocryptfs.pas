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

function dumpMasterKey(path, pass: string): TInitRec;
function init(const path: string; pass: string; const longNameMax: integer = -1; const plainTextNames: boolean = False): boolean;
function mount(const cipherdir, mountpoint: string; pass: string; const ReadOnly: boolean = False; const longName: boolean = False): TMountRec;
procedure fsck(const ACipherdir: string; pass: string);
procedure getVaultInfo(const cipherdir: string);

implementation

uses
  uLogger, uUtils, ugocryptfsFsck, uConsts;

function dumpMasterKey(path, pass: string): TInitRec;
var
  p: TProcessRec;

begin
  Result.Completed := False;

  path := path + DirectorySeparator + GOCRYPTFS_CONF_FILENAME;

  p := procStart(GOCRYPTFS_XRAY_BIN, '-dumpmasterkey' + LineEnding + path, pass);
  pass := '';

  if not p.Completed then
    Exit;

  if p.ExitStatus = 0 then
  begin
    Result.Completed := True;
    Result.Output := p.Output;
  end
  else
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

function init(const path: string; pass: string; const longNameMax: integer; const plainTextNames: boolean): boolean;
var
  p: TProcessRec;
  argLongNameMax: string = '';
  argPlainTextNames: string = '';

begin
  Result := False;

  if not mkDir(path) then
    Exit;

  if (longNameMax >= 62) and (longNameMax <= 255) then
    argLongNameMax := '-longnamemax' + LineEnding + IntToStr(longNameMax) + LineEnding;

  if plainTextNames then
    argPlainTextNames := '-plaintextnames' + LineEnding;

  p := procStart(GOCRYPTFS_BIN, '-init' + LineEnding + argLongNameMax + argPlainTextNames + path, pass);
  pass := '';

  if not p.Completed then
    Exit;

  if p.ExitStatus = 0 then
  begin
    Result := True;
    addLog(RS_CREATED_SUCCESSFULLY, path);
  end
  else
    addGoCryptFsLog(p.Output, p.ExitStatus);
end;

function mount(const cipherdir, mountpoint: string; pass: string; const ReadOnly: boolean; const longName: boolean): TMountRec;
var
  p: TProcessRec;
  guid, genMountPoint: string;
  cmd: string = '';
  shortGuid: TStringArray;

begin
  Result.Completed := False;

  guid := TGUID.NewGuid.ToString(True);

  if not longName then
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

  p := procStart(GOCRYPTFS_BIN, cmd, pass);
  pass := '';

  if not p.Completed then
  begin
    deldir(genMountPoint);
    Exit;
  end;

  if p.ExitStatus = 0 then
  begin
    Result.Completed := True;
    Result.Point := genMountPoint;
    addLog(RS_SUCCESSFULLY_MOUNTED, genMountPoint);
  end
  else
  begin
    deldir(genMountPoint);
    addGoCryptFsLog(p.Output, p.ExitStatus);
  end;
end;

procedure fsck(const ACipherdir: string; pass: string);
begin
  with TFsckThread.Create(True) do
  begin
    Cipherdir := ACipherdir;
    Password := pass;
    pass := '';
    Start;
  end;
end;

procedure getVaultInfo(const cipherdir: string);
var
  p: TProcessRec;

begin
  p := procStart(GOCRYPTFS_BIN, '-info' + LineEnding + cipherdir);

  if p.Completed then
    addGoCryptFsLog(p.Output + LineEnding + cipherdir, p.ExitStatus, True, True);
end;

end.
