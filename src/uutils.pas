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

  TMountRec = record
    Completed: boolean;
    Point: string;
  end;

function mkDir(const dir: string): boolean;
function delDir(const dir: string): boolean;
function dirExists(const dir: string): boolean;
function isDirEmpty(const dir: string): boolean;
function umount(const mountpoint: string): boolean;
function mount(const cipherdir, mountpoint, pass: string; const ReadOnly: boolean = False): TMountRec;
function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''): TProcessRec;
function getRandomName(const ALength: integer; const charSequence: string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'): string;

resourcestring
  DIRECTORY_NOT_EXISTS = 'Directory not exists';
  ERROR_CREATING_DIRECTORY = 'Error creating the directory';
  ERROR_DEL_DIRECTORY = 'Error deleting the directory';
  ERROR_WRONG_PASSWORD = 'Error, something went wrong reading the password';
  PASSWORD_EMPTY = 'Password Empty';
  PASSWORD_INCORRECT = 'Password Incorrect';
  SUCCESSFULLY_MOUNTED = 'successfully mounted';
  UNMOUNTED_SUCCESSFULLY = 'unmounted successfully';

implementation

uses
  uLogger;

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

    sl.Add(cipherdir);
    sl.Add(genMountPoint);

    if ReadOnly then
      sl.Add('-ro');

    p := ProcStart('gocryptfs', sl, pass);

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

    if (p.ExitStatus = 9) then
      addErrLog(ERROR_WRONG_PASSWORD)
    else if (p.ExitStatus = 12) then
      addErrLog(PASSWORD_INCORRECT)
    else if (p.ExitStatus = 22) then
      addErrLog(PASSWORD_EMPTY)
    else
      addErrLog(p.Output);
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

    p := ProcStart('fusermount', sl);

  finally
    FreeAndNil(sl);
  end;

  if p.Completed and (p.ExitStatus = 0) then
  begin
    deldir(mountpoint);
    addLog(ExtractFileName(mountpoint), UNMOUNTED_SUCCESSFULLY);
    Result := True;
  end
  else
    addErrLog(p.Output);
end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; stdin: string = ''): TProcessRec;
var
  p: TProcess;

begin
  Result.Completed := False;
  Result.ExitStatus := -1;

  stdin += LineEnding;

  try
    try
      p := TProcess.Create(nil);

      p.Executable := AExecutable;
      p.Parameters := AParameters;
      p.Options := [poStderrToOutPut, poUsePipes];

      p.Execute;

      if stdin <> '' then
      begin
        p.Input.Write(stdin[1], stdin.Length);
        p.CloseInput;
      end;

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
      addErrExecLog(AExecutable);
    end;
  finally
    FreeAndNil(p);
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
