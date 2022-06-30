unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure addLog(title: string; const msg: string = '');
procedure addGoCryptFsLog(const output: string; const exitStatus: integer);
procedure addErrLog(title: string; const msg: string = '');

implementation

uses
  uMainForm;

resourcestring
  ERROR_WRONG_PASSWORD = 'Error, something went wrong reading the password';
  PASSWORD_EMPTY = 'Password Empty';
  PASSWORD_INCORRECT = 'Password Incorrect';

procedure addGoCryptFsLog(const output: string; const exitStatus: integer);
begin
  case exitStatus of
    0: addLog(output);
    9: addErrLog(ERROR_WRONG_PASSWORD);
    12: addErrLog(PASSWORD_INCORRECT);
    22: addErrLog(PASSWORD_EMPTY)
    else
      addErrLog(output);
  end;
end;

procedure addErrLog(title: string; const msg: string);
begin
  if msg <> '' then
    title := title + LineEnding + msg;

  frmMain.addSynLog('! ' + title, true);
end;

procedure addLog(title: string; const msg: string);
begin
  if msg <> '' then
    title := title + LineEnding + msg;

  frmMain.addSynLog('# ' + title);
end;

end.
