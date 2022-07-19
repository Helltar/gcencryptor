unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure addLog(title: string; const msg: string = ''; const showForm: boolean = False; const isSimpleText: boolean = False);
procedure addGoCryptFsLog(const output: string; const exitStatus: integer; const showForm: boolean = False; const isSimpleText: boolean = False);
procedure addErrLog(title: string; const msg: string = ''; const showForm: boolean = True);

implementation

uses
  uMainForm, uConsts;

procedure addGoCryptFsLog(const output: string; const exitStatus: integer; const showForm: boolean; const isSimpleText: boolean);
begin
  case exitStatus of
    0: addLog(output, '', showForm, isSimpleText);
    9: addErrLog(RS_ERROR_WRONG_PASSWORD);
    12: addErrLog(RS_PASSWORD_INCORRECT);
    22: addErrLog(RS_PASSWORD_EMPTY)
    else
      addErrLog(output);
  end;
end;

procedure addErrLog(title: string; const msg: string; const showForm: boolean);
begin
  if msg <> '' then
    title := title + LineEnding + msg;

  frmMain.addSynLog('''! ' + title, True, showForm);
  WriteLn('! ' + title);
end;

procedure addLog(title: string; const msg: string; const showForm: boolean; const isSimpleText: boolean);
var
  prefix: string = '# ';

begin
  if msg <> '' then
    title := title + LineEnding + msg;

  if isSimpleText then
    prefix := LineEnding;

  if showForm then
    frmMain.addSynLog(prefix + title, False, showForm)
  else
    WriteLn(title);
end;

end.
