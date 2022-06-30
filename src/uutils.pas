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

function umount(const mountpoint: string): boolean;
function mkDir(const dir: string): boolean;
function delDir(const dir: string): boolean;
function dirExists(const dir: string): boolean;
function isDirEmpty(const dir: string): boolean;
function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''): TProcessRec;
function getRandomName(const ALength: integer; const charSequence: string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'): string;

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

function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''): TProcessRec;
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
        stdin := stdin + LineEnding;
        p.Input.Write(stdin[1], stdin.Length);
        stdin := '******';
        stdin := '';
      end;

       Sleep(300); // large output, trick

      with TStringList.Create do
        try
          LoadFromStream(p.Output);
          Result.Output := Text;
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
  sl: TStringList;

begin
  Result := False;

  try
    sl := TStringList.Create;

    sl.Add('-u');
    sl.Add(mountpoint);

    p := ProcStart(FUSERMOUNT_BIN, sl);

  finally
    FreeAndNil(sl);
  end;

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
