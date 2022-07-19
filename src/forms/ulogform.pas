unit uLogForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, SynEdit, synhighlighterunixshellscript, SynHighlighterHTML,
  SynExportHTML, LCLType;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure timerTimer(Sender: TObject);
  private
    function isNotBinInstalled(const executable: string): boolean;
  public
    procedure addSynLog(const msg: string; const err: boolean = False);
    procedure waitOnThreadFinish();
  end;

var
  frmLog: TfrmLog;

implementation

uses
  uMainForm, ugocryptfsFsck, uUtils, uConsts, uLogger;

{$R *.lfm}

{ TfrmLog }

procedure TfrmLog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLog.btnClearClick(Sender: TObject);
begin
  synLog.Clear;
end;

function TfrmLog.isNotBinInstalled(const executable: string): boolean;
begin
  Result := not procStart(executable, '').Completed;
end;

procedure TfrmLog.btnSaveLogClick(Sender: TObject);
begin
  saveDialog.FileName := getAppOriginalFilename() + '_' + getAppFileVersion() + '_' + FormatDateTime('yyy-mm-dd_hh-nn-ss', Now) + '_log';

  if saveDialog.Execute then
    with TSynExporterHTML.Create(nil) do
      try
        try
          Title := getAppOriginalFilename();
          Highlighter := synLog.Highlighter;
          ExportAll(synLog.Lines);
          SaveToFile(saveDialog.FileName + '.html');
        except
          addSynLog(RS_FAILED_TO_SAVE_LOG_FILE + LineEnding + saveDialog.FileName, True);
        end;
      finally
        Free;
      end;
end;

procedure TfrmLog.FormCreate(Sender: TObject);
begin
  Caption := APP_NAME + ' - ' + Caption;
  Height := frmMain.config.frmLogHeight;
  Width := frmMain.config.frmLogWidth;
  saveDialog.InitialDir := GetUserDir;

  if isNotBinInstalled(GOCRYPTFS_BIN) then
    addErrLog(Format(RS_BIN_NOT_INSTALLED, [GOCRYPTFS_BIN]), URL_GOCRYPTFS);

  if isNotBinInstalled(FUSERMOUNT_BIN) then
    addErrLog(Format(RS_BIN_NOT_INSTALLED, [FUSERMOUNT_BIN]));

  if isNotBinInstalled(FUSER_BIN) then
    addErrLog(Format(RS_BIN_NOT_INSTALLED, [FUSER_BIN]));

  if isNotBinInstalled(GOCRYPTFS_XRAY_BIN) then
    addErrLog(Format(RS_BIN_NOT_INSTALLED, [GOCRYPTFS_XRAY_BIN]),
      URL_GOCRYPTFS + LineEnding + RS_GOCRYPTFS_XRAY_FAILED_RUN_HINT);
end;

procedure TfrmLog.FormDestroy(Sender: TObject);
begin
  frmMain.config.frmLogHeight := Height;
  frmMain.config.frmLogWidth := Width;
end;

procedure TfrmLog.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_Q) and (ssCtrl in Shift) then
    Close;
end;

procedure TfrmLog.FormShow(Sender: TObject);
begin
  synLog.Font.Size := frmMain.config.logFontSize;
end;

procedure TfrmLog.timerTimer(Sender: TObject);
begin
  if isFsckThreadStopped then
  begin
    btnClear.Enabled := True;
    btnClose.Enabled := True;
    btnSaveLog.Enabled := True;
    Cursor := crDefault;
    synLog.Enabled := True;
    timer.Enabled := False;
  end;
end;

procedure TfrmLog.addSynLog(const msg: string; const err: boolean);
var
  i: integer;
  s: TStringList;
  tab: string = '          ';

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

  synLog.Append(TimeToStr(Time) + ': ' + s[0]); // title

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
  btnClear.Enabled := False;
  btnClose.Enabled := False;
  btnSaveLog.Enabled := False;
  Cursor := crAppStart;
  synLog.Enabled := False;
  timer.Enabled := True;
end;

end.
