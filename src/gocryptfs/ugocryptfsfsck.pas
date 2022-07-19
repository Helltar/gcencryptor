unit ugocryptfsFsck;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  //-----
  uUtils;

type

  { TFsckThread }

  TFsckThread = class(TThread)
  private
    FCipherdir: string;
    FPassword: string;
    p: TProcessRec;
    procedure addOkLog;
    procedure addWaitText;
    procedure addErrorLog;
    procedure SetCipherdir(AValue: string);
    procedure SetPassword(AValue: string);
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
    property Cipherdir: string read FCipherdir write SetCipherdir;
    property Password: string read FPassword write SetPassword;
  end;

var
  isFsckThreadStopped: boolean = True;

implementation

uses
  uLogger, uConsts;

constructor TFsckThread.Create(CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
end;

procedure TFsckThread.Execute;
begin
  isFsckThreadStopped := False;

  Synchronize(@addWaitText);

  // -q, -quiet silence informational messages
  p := procStart(GOCRYPTFS_BIN, '-q' + LineEnding + '-fsck' + LineEnding + FCipherdir, FPassword);
  FPassword := '';

  if p.Completed then
    if p.ExitStatus = 0 then
      Synchronize(@addOkLog)
    else
      Synchronize(@addErrorLog);

  isFsckThreadStopped := True;
end;

procedure TFsckThread.addOkLog;
begin
  addLog(RS_FSCK_NO_PROBLEMS_FOUND, '', True);
end;

procedure TFsckThread.addWaitText;
begin
  addLog(RS_PLEASE_WAIT_UNTIL_THE_PROCESS, '', True);
end;

procedure TFsckThread.addErrorLog;
begin
  addGoCryptFsLog(p.Output + LineEnding + FCipherdir, p.ExitStatus);
end;

procedure TFsckThread.SetCipherdir(AValue: string);
begin
  FCipherdir := AValue;
end;

procedure TFsckThread.SetPassword(AValue: string);
begin
  FPassword := AValue;
end;

end.
