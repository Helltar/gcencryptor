unit uLogForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, SynEdit,
  synhighlighterunixshellscript;

type

  { TfrmLog }

  TfrmLog = class(TForm)
    synLog: TSynEdit;
    synUNIXShellScriptSyn: TSynUNIXShellScriptSyn;
    procedure FormShow(Sender: TObject);
  private

  public
    procedure addSynLog(const msg: string; const err: boolean = False);
  end;

var
  frmLog: TfrmLog;

implementation

uses
  uMainForm;

{$R *.lfm}

{ TfrmLog }

procedure TfrmLog.FormShow(Sender: TObject);
begin
  synLog.Font.Size := frmMain.config.logFontSize;
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

end.
