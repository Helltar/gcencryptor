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
function getRandomName(const ALength: integer; const charSequence: string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'): string;
function isDirEmpty(const dir: string): boolean;
function mkDir(const dir: string): boolean;
function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''; const isMount: boolean = False): TProcessRec;
function procStart(const executable, parameters: string; const stdin: string = ''; const isMount: boolean = False): TProcessRec;
function umount(const mountpoint: string): boolean;

implementation

uses
  uLogger;

resourcestring
  DIRECTORY_NOT_EXISTS = 'Directory not exists';
  ERROR_CREATING_DIRECTORY = 'Error creating the directory';
  ERROR_DEL_DIRECTORY = 'Error deleting the directory';
  ERROR_RUN_EXECUTABLE = 'failed to run';
  UNMOUNTED_SUCCESSFULLY = 'Unmounted successfully';

const
  FUSERMOUNT_BIN = 'fusermount';

function procStart(const executable, parameters: string; const stdin: string; const isMount: boolean): TProcessRec;
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

  Result := ProcStart(executable, s1, stdin, isMount);

  FreeAndNil(s);
  FreeAndNil(s1);
end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string; const isMount: boolean): TProcessRec;
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

      with TStringList.Create do
        try
          repeat
            LoadFromStream(p.Output);
            Result.Output += Text;
          until not p.Running or isMount;
        finally
          Free;
        end;

      Result.Completed := p.WaitOnExit();
      Result.ExitStatus := p.ExitStatus;

    except
      addErrLog(AExecutable, ERROR_RUN_EXECUTABLE);
    end;
  finally
    FreeAndNil(p);
  end;
end;

function umount(const mountpoint: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

  p := procStart(FUSERMOUNT_BIN, '-u' + LineEnding + mountpoint);

  if p.Completed and (p.ExitStatus = 0) then
  begin
    deldir(mountpoint);
    addLog(UNMOUNTED_SUCCESSFULLY, mountpoint);
    Result := True;
  end
  else
    addErrLog(p.Output);
end;

function dirExists(const dir: string): boolean;
begin
  Result := False;

  if DirectoryExists(dir) then
    Result := True
  else
    addErrLog(DIRECTORY_NOT_EXISTS, dir);
end;

function getRandomName(const ALength: integer; const charSequence: string): string;
var
  ch, sLength: integer;

begin
  sLength := Length(charSequence);
  SetLength(Result, ALength);

  Randomize;

  for ch := Low(Result) to High(Result) do
    Result[ch] := charSequence.Chars[Random(sLength)];

  Result := UpperCase(Result);
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
