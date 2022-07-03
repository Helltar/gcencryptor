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
  { ---------------------------------------------------------------- }
  uMainForm, uSettingsForm, uNewVaultForm, uAboutForm, uMasterKeyForm,
  uMountList, ugocryptfs;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
