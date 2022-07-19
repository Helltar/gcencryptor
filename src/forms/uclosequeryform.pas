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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  public
    CloseQueryResult: boolean;
  end;

implementation

{$R *.lfm}

{ TfrmCloseQuery }

procedure TfrmCloseQuery.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCloseQuery.FormCreate(Sender: TObject);
begin
  CloseQueryResult := False;
end;

procedure TfrmCloseQuery.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width + 60; // gtk, caption
end;

procedure TfrmCloseQuery.btnYesClick(Sender: TObject);
begin
  CloseQueryResult := True;
  Close;
end;

end.
