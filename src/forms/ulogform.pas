unit uLogForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, SynEdit,
  synhighlighterunixshellscript;

type

  { TfrmLog }

  TfrmLog = class(TForm)
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    timer: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure timerTimer(Sender: TObject);
  private

  public
    procedure addSynLog(const msg: string; const err: boolean = False);
    procedure waitOnThreadFinish();
  end;

var
  frmLog: TfrmLog;

implementation

uses
  uMainForm, ugocryptfsFsck;

resourcestring
  PLEASE_WAIT_UNTIL_THE_PROCESS = 'Please wait until the process is completed it may take some time ...';

{$R *.lfm}

{ TfrmLog }

procedure TfrmLog.FormShow(Sender: TObject);
begin
  synLog.Font.Size := frmMain.config.logFontSize;
end;

procedure TfrmLog.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmMain.updateControls();
end;

procedure TfrmLog.timerTimer(Sender: TObject);
begin
  Cursor := crAppStart;
  synLog.Enabled := False;

  if isFsckThreadStopped then
  begin
    Cursor := crDefault;
    synLog.Enabled := True;
    timer.Enabled := False;
  end;
end;

procedure TfrmLog.addSynLog(const msg: string; const err: boolean);
var
  i: integer;
  s: TStringList;

begin
  s := TStringList.Create;
  s.Text := msg;
  s.Delimiter := LineEnding;

  synLog.Clear;
  synLog.Lines.Add(s[0]);

  // 'wordwrap'
  for i := 1 to s.Count - 1 do
    synLog.Lines.Add('  - ' + s[i]);

  synLog.Lines.Add(LineEnding);

  if not err then
  begin
    synLog.LineHighlightColor.Foreground := clBlack;
    synLog.LineHighlightColor.Background := $98FB98; // PaleGreen
  end
  else
  begin
    synLog.LineHighlightColor.Foreground := clWhite;
    synLog.LineHighlightColor.Background := clRed;
  end;

  // scroll down
  synLog.CaretY := synLog.Lines.Count;
  synLog.CaretY := synLog.Lines.Count - s.Count;

  FreeAndNil(s);
end;

procedure TfrmLog.waitOnThreadFinish;
begin
  addSynLog(PLEASE_WAIT_UNTIL_THE_PROCESS);
  timer.Enabled := True;
  ShowModal;
end;

end.
