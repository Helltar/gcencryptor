unit uLogForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  SynEdit, synhighlighterunixshellscript;

type

  { TfrmLog }

  TfrmLog = class(TForm)
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    timer: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure timerTimer(Sender: TObject);
  private

  public
    procedure addSynLog(const msg: string; const err: boolean = False; const highlight: boolean = True);
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

procedure TfrmLog.FormCreate(Sender: TObject);
begin
  Height := frmMain.config.frmLogHeight;
  Width := frmMain.config.frmLogWidth;
end;

procedure TfrmLog.FormDestroy(Sender: TObject);
begin
  frmMain.config.frmLogHeight := Height;
  frmMain.config.frmLogWidth := Width;
end;

procedure TfrmLog.timerTimer(Sender: TObject);
begin
  if isFsckThreadStopped then
  begin
    Cursor := crDefault;
    synLog.Enabled := True;
    timer.Enabled := False;
  end;
end;

procedure TfrmLog.addSynLog(const msg: string; const err: boolean; const highlight: boolean);
var
  i: integer;
  s: TStringList;
  tab: string = '';

begin
  synLog.Clear;
  synLog.LineHighlightColor.Foreground := clNone;
  synLog.LineHighlightColor.Background := clNone;

  if highlight then
  begin
    tab := '  - ';

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
  end;

  s := TStringList.Create;
  s.Text := msg;
  s.Delimiter := LineEnding;

  synLog.Append(s[0]);

  // 'wordwrap'
  for i := 1 to s.Count - 1 do
    synLog.Append(tab + s[i]);

  synLog.Append(LineEnding);

  if not highlight then
    synLog.CaretY := synLog.Lines.Count;

  FreeAndNil(s);
end;

procedure TfrmLog.waitOnThreadFinish;
begin
  addSynLog(PLEASE_WAIT_UNTIL_THE_PROCESS);

  Cursor := crAppStart;
  synLog.Enabled := False;
  timer.Enabled := True;

  Show;
end;

end.
