unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure addLog(title: string; const msg: string = ''; const showForm: boolean = False; const highlight: boolean = True);
procedure addGoCryptFsLog(const output: string; const exitStatus: integer; const showForm: boolean = False; const highlight: boolean = True);
procedure addErrLog(title: string; const msg: string = '');

implementation

uses
  uLogForm;

resourcestring
  ERROR_WRONG_PASSWORD = 'Error, something went wrong reading the password';
  PASSWORD_EMPTY = 'Password Empty';
  PASSWORD_INCORRECT = 'Password Incorrect';

procedure addGoCryptFsLog(const output: string; const exitStatus: integer; const showForm: boolean; const highlight: boolean);
begin
  case exitStatus of
    0: addLog(output, '', showForm, highlight);
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

  frmLog.addSynLog('! ' + title, True);
  frmLog.Show;
end;

procedure addLog(title: string; const msg: string; const showForm: boolean; const highlight: boolean);
begin
  if msg <> '' then
    title := title + LineEnding + msg;

  if highlight then
    frmLog.addSynLog('# ' + title)
  else
    frmLog.addSynLog(title, False, False);

  if showForm then
    frmLog.Show;
end;

end.
