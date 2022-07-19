program gcencryptor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Forms, Interfaces, Classes, FileUtil, process, SysUtils,
  uMainForm, uLogForm,
  uUtils, uConsts;

{$R *.res}

var
  p: TProcessRec;

begin
  p := procStart('pgrep', APP_NAME);

  if p.Completed and (p.ExitStatus = 0) then
    with TStringList.Create do
      try
        Text := p.Output;
        if Count > 1 then
          Exit;
        WriteLn(Text);
      finally
        Free;
      end;

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLog, frmLog);
  Application.Run;
end.
