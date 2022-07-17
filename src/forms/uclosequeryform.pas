unit uCloseQueryForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmCloseQuery }

  TfrmCloseQuery = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    CloseQueryResult: boolean;
  end;

implementation

{$R *.lfm}

{ TfrmCloseQuery }

procedure TfrmCloseQuery.Button2Click(Sender: TObject);
begin
  CloseQueryResult := False;
  Close;
end;

procedure TfrmCloseQuery.FormShow(Sender: TObject);
begin
    Constraints.MinHeight:=Height;
  Constraints.MinWidth:=Width;
    Constraints.MaxHeight:=Height;
  Constraints.MaxWidth:=Width;
end;

procedure TfrmCloseQuery.Button1Click(Sender: TObject);
begin
  CloseQueryResult := True;
  Close;
end;

end.
