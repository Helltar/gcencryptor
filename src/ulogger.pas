unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure addLog(const msg: string);
procedure addLog(const msg, output: string);
procedure addErrLog(const msg: string);
procedure addErrLog(const title, msg: string);
procedure addErrExecLog(const executable: string);

resourcestring
  ERROR_RUN_EXECUTABLE = 'failed to run';

implementation

uses
  uMainForm;

procedure addErrLog(const msg: string);
begin
  frmMain.synLog.Lines.Add('! ' + msg);
end;

procedure addErrLog(const title, msg: string);
begin
  addErrLog(title + ': ' + msg);
end;

procedure addErrExecLog(const executable: string);
begin
  addErrLog(executable, ERROR_RUN_EXECUTABLE);
end;

procedure addLog(const msg: string);
begin
  frmMain.synLog.Lines.Add('# ' + msg);
end;

procedure addLog(const msg, output: string);
begin
  addLog(msg + ': ' + output);
end;

end.
