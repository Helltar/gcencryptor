unit uLogForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, SynEdit, synhighlighterunixshellscript;

type

  { TfrmLog }

  TfrmLog = class(TForm)
    btnSaveLog: TButton;
    btnClear: TButton;
    btnClose: TButton;
    saveDialog: TSaveDialog;
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    timer: TTimer;
    procedure btnSaveLogClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure timerTimer(Sender: TObject);

  public
    procedure addSynLog(const msg: string; const err: boolean = False);
    procedure waitOnThreadFinish();
  end;

var
  frmLog: TfrmLog;

implementation

uses
  uMainForm, ugocryptfsFsck, uLogger;

resourcestring
  PLEASE_WAIT_UNTIL_THE_PROCESS = 'Please wait until the process is completed it may take some time ...';
  FAILED_TO_SAVE_LOG_FILE = 'Failed to save log file';

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

procedure TfrmLog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLog.btnClearClick(Sender: TObject);
begin
  synLog.Clear;
end;

procedure TfrmLog.btnSaveLogClick(Sender: TObject);
begin
  saveDialog.FileName := 'gcencryptor_' + FormatDateTime('yyy-mm-dd_hh-nn-ss', Now) + '.log';

  if saveDialog.Execute then
    try
      synLog.Lines.SaveToFile(saveDialog.FileName);
    except
      addErrLog(FAILED_TO_SAVE_LOG_FILE, saveDialog.FileName);
    end;
end;

procedure TfrmLog.FormCreate(Sender: TObject);
begin
  Height := frmMain.config.frmLogHeight;
  Width := frmMain.config.frmLogWidth;
  saveDialog.InitialDir := GetUserDir;
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

procedure TfrmLog.addSynLog(const msg: string; const err: boolean);
var
  i: integer;
  s: TStringList;
  tab: string = '        ';

begin
  synLog.LineHighlightColor.Foreground := clNone;
  synLog.LineHighlightColor.Background := clNone;

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

  s := TStringList.Create;
  s.Text := msg;
  s.Delimiter := LineEnding;

  synLog.Append(TimeToStr(Time));
  synLog.Append(tab + s[0]);

  // 'wordwrap'
  for i := 1 to s.Count - 1 do
    synLog.Append(tab + s[i]);

  synLog.Append(LineEnding);

  // scroll down
  synLog.CaretY := synLog.Lines.Count;
  synLog.CaretY := synLog.Lines.Count - s.Count;

  FreeAndNil(s);
end;

procedure TfrmLog.waitOnThreadFinish;
begin
  addLog(PLEASE_WAIT_UNTIL_THE_PROCESS);

  Cursor := crAppStart;
  synLog.Enabled := False;
  timer.Enabled := True;

  Show;
end;

end.
