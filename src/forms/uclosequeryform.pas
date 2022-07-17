unit uCloseQueryForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmCloseQuery }

  TfrmCloseQuery = class(TForm)
    btnYes: TButton;
    btnCancel: TButton;
    lblQ: TLabel;
    lblUnlockedVaults: TLabel;
    lblInfo: TLabel;
    stVaultList: TStaticText;
    procedure btnYesClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    CloseQueryResult: boolean;
  end;

implementation

{$R *.lfm}

{ TfrmCloseQuery }

procedure TfrmCloseQuery.btnCancelClick(Sender: TObject);
begin
  CloseQueryResult := False;
  Close;
end;

procedure TfrmCloseQuery.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := Height;
  Constraints.MaxWidth := Width;
end;

procedure TfrmCloseQuery.btnYesClick(Sender: TObject);
begin
  CloseQueryResult := True;
  Close;
end;

end.
