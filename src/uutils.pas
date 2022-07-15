unit uUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil;

type
  TProcessRec = record
    Completed: boolean;
    Output: string;
    ExitStatus: integer;
  end;

function delDir(const dir: string): boolean;
function dirExists(const dir: string): boolean;
function isDirEmpty(const dir: string): boolean;
function mkDir(const dir: string): boolean;
function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''): TProcessRec;
function procStart(const executable, parameters: string; stdin: string = ''): TProcessRec;
function umount(const mountpoint: string): boolean;
function findmnt(const path: string): boolean;

implementation

uses
  uLogger;

resourcestring
  DIRECTORY_NOT_EXISTS = 'Directory not exists';
  ERROR_CREATING_DIRECTORY = 'Error creating the directory';
  ERROR_DEL_DIRECTORY = 'Error deleting the directory';
  ERROR_RUN_EXECUTABLE = 'failed to run';
  UNMOUNTED_SUCCESSFULLY = 'Unmounted successfully';

function procStart(const executable, parameters: string; stdin: string): TProcessRec;
var
  i: integer;
  s, s1: TStringList;

begin
  s := TStringList.Create;
  s1 := TStringList.Create;

  s.Text := parameters;
  s.Delimiter := LineEnding;

  for i := 0 to s.Count - 1 do
    s1.Add(s[i]);

  Result := ProcStart(executable, s1, stdin);
  stdin := '';

  FreeAndNil(s);
  FreeAndNil(s1);
end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string): TProcessRec;
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

      if stdin <> '' then
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
      addErrLog(AExecutable, ERROR_RUN_EXECUTABLE);
    end;
  finally
    FreeAndNil(p);
  end;
end;

function findmnt(const path: string): boolean;
var
  p: TProcessRec;

begin
  p := procStart('findmnt', path);
  Result := p.Completed and (p.ExitStatus = 0);
end;

function umount(const mountpoint: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

  p := procStart('fusermount', '-u' + LineEnding + mountpoint);

  if p.Completed then
  begin
    if p.ExitStatus <> 0 then
      // if find path in /etc/mtab (findmnt), then fusermount -> device busy, etc.
      // else was unmounted in another way: result true
      if findmnt(mountpoint) then
      begin
        addErrLog(p.Output);
        Exit;
      end;

    deldir(mountpoint);
    addLog(UNMOUNTED_SUCCESSFULLY, mountpoint);

    Result := True;
  end;
end;

function dirExists(const dir: string): boolean;
begin
  Result := False;

  if DirectoryExists(dir) then
    Result := True
  else
    addErrLog(DIRECTORY_NOT_EXISTS, dir);
end;

function mkDir(const dir: string): boolean;
begin
  Result := False;

  if CreateDir(dir) then
    Result := True
  else
    addErrLog(ERROR_CREATING_DIRECTORY, dir);
end;

function delDir(const dir: string): boolean;
begin
  Result := False;

  if isDirEmpty(dir) then
    if DeleteDirectory(dir, False) then
      Result := True;

  if not Result then
    addErrLog(ERROR_DEL_DIRECTORY, dir);
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

end.
