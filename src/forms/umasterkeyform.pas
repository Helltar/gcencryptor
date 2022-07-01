unit uMasterKeyForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls;

type

  { TfrmMasterKey }

  TfrmMasterKey = class(TForm)
    btnSave: TButton;
    btnOK: TButton;
    edtKey: TEdit;
    lblYourKey: TLabel;
    saveDialog: TSaveDialog;
    stText: TStaticText;
    procedure btnOKClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  public
    vaultName: string;
  end;

implementation

uses
  uLogger;

resourcestring
  KEY_SAVED = 'Key successfully saved';
  ERR_SAVE_KEY = 'Error when saving key';

{$R *.lfm}

{ TfrmMasterKey }

procedure TfrmMasterKey.btnSaveClick(Sender: TObject);
begin
  saveDialog.FileName := LowerCase(vaultName) + '.masterkey';

  if saveDialog.Execute then
    with TStringList.Create do
      try
        Text := edtKey.Text;
        try
          SaveToFile(saveDialog.FileName);
          addLog(KEY_SAVED);
        except
          addErrLog(ERR_SAVE_KEY, saveDialog.FileName);
        end;
      finally
        Free;
        Close;
      end;
end;

procedure TfrmMasterKey.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
end;

procedure TfrmMasterKey.btnOKClick(Sender: TObject);
begin
  Close;
end;

end.
