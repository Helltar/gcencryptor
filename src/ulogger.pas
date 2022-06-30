unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure addLog(title: string; const msg: string = '');
procedure addGoCryptFsLog(const output: string; const exitStatus: integer);
procedure addErrLog(title: string; const msg: string = '');
procedure addSynEditLog(const msg: string);

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

  addSynEditLog('! ' + title);
end;

procedure addLog(title: string; const msg: string);
begin
  if msg <> '' then
    title := title + LineEnding + msg;

  addSynEditLog('# ' + title);
end;

procedure addSynEditLog(const msg: string);
var
  i: integer;
  s: TStringList;

begin
  s := TStringList.Create;
  s.Text := msg;
  s.Delimiter := LineEnding;

  frmMain.synLog.Lines.Add(s[0]);

  // synedit 'wordwrap'
  for i := 1 to s.Count - 1 do
    frmMain.synLog.Lines.Add('  - ' + s[i]);

  FreeAndNil(s);

  frmMain.synLog.Lines.Add(LineEnding);
end;

end.
