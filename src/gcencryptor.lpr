program gcencryptor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Forms, Interfaces,
  //----------------------------------------------------------------------------
  uMainForm, uSettingsForm, uNewVaultForm, uAboutForm, uMasterKeyForm, uLogForm,
  uMountList, ugocryptfs, ugocryptfsFsck;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLog, frmLog);
  Application.Run;
end.
