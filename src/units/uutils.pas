unit uUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, fileinfo;

type
  TProcessRec = record
    Completed: boolean;
    Output: string;
    ExitStatus: integer;
  end;

//function findmnt(const path: string): boolean;
function delDir(const dir: string; const showErr: boolean = True): boolean;
function dirExists(const dir: string): boolean;
function fuserCheck(const mountpoint: string): boolean;
function getAppFileVersion(): string;
function getAppInfo(const AType: string): string;
function getAppOriginalFilename(): string;
function getFuserOutput(const mountpoint: string): string;
function isDirEmpty(const dir: string): boolean;
function mkDir(const dir: string): boolean;
function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''; const showFormIfErr: boolean = True): TProcessRec;
function procStart(const executable, parameters: string; stdin: string = ''; const showFormIfErr: boolean = True): TProcessRec;
function umount(const mountpoint: string): boolean;
function getDirSize(const path: string): string;

implementation

uses
  uLogger, uConsts;

function procStart(const executable, parameters: string; stdin: string; const showFormIfErr: boolean): TProcessRec;
var
  s, s1: TStringList;
  ss: string;

begin
  s := TStringList.Create;
  s1 := TStringList.Create;

  s.Text := parameters;
  s.Delimiter := LineEnding;

  for ss in s do
    s1.Add(ss);

  Result := ProcStart(executable, s1, stdin, showFormIfErr);
  stdin := '';

  FreeAndNil(s);
  FreeAndNil(s1);
end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string; const showFormIfErr: boolean): TProcessRec;
var
  p: TProcess;

begin
  Result.Completed := False;
  Result.ExitStatus := -1;

  try
    p := TProcess.Create(nil);
    p.Executable := AExecutable;
    p.Parameters := AParameters;
    p.Options := [poStderrToOutPut, poUsePipes];

    try
      p.Execute;

      if not stdin.IsEmpty then
      begin
        stdin += LineEnding;
        p.Input.Write(stdin[1], Length(stdin));
        stdin := '******';
        stdin := '';
      end;

      Result.Completed := p.WaitOnExit();
      Result.ExitStatus := p.ExitStatus;

      with TStringList.Create do
        try
          LoadFromStream(p.Output);
          Result.Output := Text;
        finally
          Free;
        end;
    except
      addErrLog(AExecutable, RS_ERROR_RUN_EXECUTABLE, showFormIfErr);
    end;
  finally
    FreeAndNil(p);
  end;
end;

{
function findmnt(const path: string): boolean;
var
  p: TProcessRec;

begin
  p := procStart('findmnt', path);

  if p.Completed and (p.ExitStatus = 0) then
    Result := True
  else
    Result := False;
end;
}
function umount(const mountpoint: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

  p := procStart(FUSERMOUNT_BIN, '-u' + LineEnding + mountpoint);

  if not p.Completed then
    Exit;

  if p.ExitStatus <> 0 then
    // check if unmounted in another way, outside the application
    if fuserCheck(mountpoint) then
    begin
      // if not, fusermount -> device busy, etc ...
      addErrLog(p.Output);
      addErrLog(getFuserOutput(mountpoint));
      Exit;
    end;

  deldir(mountpoint, False);
  addLog(RS_UNMOUNTED_SUCCESSFULLY, mountpoint);
  Result := True;
end;

function getDirSize(const path: string): string;
var
  p: TProcessRec;

begin
  p := procStart('du', '-sh' + LineEnding + path, '', False);
  if p.Completed and (p.ExitStatus = 0) then
    Result := Trim(StringReplace(p.Output, path, '', [rfReplaceAll]))
  else
    Result := '0b';
end;

function dirExists(const dir: string): boolean;
begin
  Result := False;

  if DirectoryExists(dir) then
    Result := True
  else
    addErrLog(RS_DIRECTORY_NOT_EXISTS, dir);
end;

function mkDir(const dir: string): boolean;
begin
  Result := False;

  if CreateDir(dir) then
    Result := True
  else
    addErrLog(RS_ERROR_CREATING_DIRECTORY, dir);
end;

function delDir(const dir: string; const showErr: boolean): boolean;
begin
  Result := False;

  if isDirEmpty(dir) then
    if DeleteDirectory(dir, False) then
      Result := True;

  if not Result then
    if showErr then
      addErrLog(RS_ERROR_DEL_DIRECTORY, dir)
    else
      addErrLog(RS_ERROR_DEL_DIRECTORY, dir, False);
end;

function isDirEmpty(const dir: string): boolean;
var
  sr: TSearchRec;
  i: integer;

begin
  Result := False;

  FindFirst(IncludeTrailingPathDelimiter(dir) + '*', faAnyFile, sr);

  for i := 1 to 2 do
    if (sr.Name = '.') or (sr.Name = '..') then
      Result := FindNext(sr) <> 0;

  FindClose(sr);
end;

{---------------------------------------------------------
  AType:
  ['CompanyName'] ['FileDescription'] ['FileVersion']
  ['InternalName'] ['LegalCopyright'] ['OriginalFilename']
  ['ProductName'] ['ProductVersion']
---------------------------------------------------------}

function getAppInfo(const AType: string): string;
begin
  Result := '1';

  with TFileVersionInfo.Create(nil) do
    try
      ReadFileInfo;
      Result := VersionStrings.Values[AType];
    finally
      Free;
    end;
end;

function getAppOriginalFilename: string;
begin
  Result := getAppInfo('OriginalFilename');
end;

function getFuserOutput(const mountpoint: string): string;
var
  p: TProcessRec;
  i: integer;
  s: TStringList;

begin
  Result := mountpoint;

  p := procStart(FUSER_BIN, '-v' + LineEnding + mountpoint);

  if not p.Completed or (p.ExitStatus <> 0) then
    Exit;

  s := TStringList.Create;
  s.Delimiter := LineEnding;
  s.Text := p.Output;

  {-----------------------------------------------------------------------------
  fuser output:
   [0] USER PID ACCESS COMMAND
   [1] /home/username/.config/gcencryptor/mnt/example_F38C3354:
   [2] root kernel mount /home/username/.config/gcencryptor/mnt/example_F38C3354
   [3] username 00000 ..c.. gwenview
   [4] ...
  -----------------------------------------------------------------------------}

  if s.Count >= 4 then
  begin
    Result := s[1] + LineEnding + s[0] + LineEnding;
    for i := 3 to s.Count - 1 do
      Result += s[i] + LineEnding;
  end;

  FreeAndNil(s);
end;

function fuserCheck(const mountpoint: string): boolean;
begin
  // check mountpoint exist
  Result := procStart(FUSER_BIN, '-v' + LineEnding + mountpoint).ExitStatus = 0;
end;

function getAppFileVersion: string;
begin
  Result := getAppInfo('FileVersion');
end;

end.
