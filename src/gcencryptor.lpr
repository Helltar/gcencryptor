program gcencryptor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Forms, Interfaces,
  SysUtils,
  uConsts, uUtils,
  uMainForm, uLogForm;

{$R *.res}

var
  configDir, lockFilename: string;

begin
  configDir := GetAppConfigDir(False);

  if not DirectoryExists(configDir) then
    mkDir(configDir);

  lockFilename := configDir + '.' + APP_NAME + '.lock';

  if not FileExists(lockFilename) then
    FileCreate(lockFilename)
  else
  if not isUniqueInstance() then
  begin
    FileCreate(lockFilename + '1');
    Exit;
  end;

  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.primaryLockFilename := lockFilename;
  Application.CreateForm(TfrmLog, frmLog);
  Application.Run;

  if Application.Terminated then
    DeleteFile(lockFilename);
end.
