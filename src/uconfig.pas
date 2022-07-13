unit uConfig;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, IniFiles;

type

  { TConfig }

  TConfig = class(TIniFile)
  private
    function GetAutorunState: boolean;
    function GetFrmHeight: integer;
    function GetFrmLeft: integer;
    function GetFrmTop: integer;
    function GetFrmWidth: integer;
    function GetLatestVaultIndex: integer;
    function GetLogFontSize: integer;
    function GetMountPoint: string;
    function GetMountPointShortName: boolean;
    function GetSplLeft: integer;
    procedure SetAutorunState(AValue: boolean);
    procedure SetFrmHeight(AValue: integer);
    procedure SetFrmLeft(AValue: integer);
    procedure SetFrmTop(AValue: integer);
    procedure SetFrmWidth(AValue: integer);
    procedure SetLatestVaultIndex(AValue: integer);
    procedure SetLogFontSize(AValue: integer);
    procedure SetMountPoint(AValue: string);
    procedure SetMountPointShortName(AValue: boolean);
    procedure SetSplLeft(AValue: integer);
  public
    property autorunState: boolean read GetAutorunState write SetAutorunState;
    property frmHeight: integer read GetFrmHeight write SetFrmHeight;
    property frmLeft: integer read GetFrmLeft write SetFrmLeft;
    property frmTop: integer read GetFrmTop write SetFrmTop;
    property frmWidth: integer read GetFrmWidth write SetFrmWidth;
    property latestVaultIndex: integer read GetLatestVaultIndex write SetLatestVaultIndex;
    property logFontSize: integer read GetLogFontSize write SetLogFontSize;
    property mountPoint: string read GetMountPoint write SetMountPoint;
    property mountPointShortName: boolean read GetMountPointShortName write SetMountPointShortName;
    property splLeft: integer read GetSplLeft write SetSplLeft;
  end;

implementation

{ TConfig }

function TConfig.GetMountPoint: string;
begin
  Result := ReadString('MAIN', 'mountPoint', GetAppConfigDir(False) + 'mnt');
end;

function TConfig.GetMountPointShortName: boolean;
begin
  Result := ReadBool('MAIN', 'mountPointShortName', False);
end;

function TConfig.GetAutorunState: boolean;
begin
  Result := ReadBool('MAIN', 'autorunState', True);
end;

function TConfig.GetFrmHeight: integer;
begin
  Result := ReadInteger('FORM', 'height', 500);
end;

function TConfig.GetFrmLeft: integer;
begin
  Result := ReadInteger('FORM', 'left', 0);
end;

function TConfig.GetFrmTop: integer;
begin
  Result := ReadInteger('FORM', 'top', 0);
end;

function TConfig.GetFrmWidth: integer;
begin
  Result := ReadInteger('FORM', 'width', 900);
end;

function TConfig.GetLatestVaultIndex: integer;
begin
  Result := ReadInteger('MAIN', 'latestVaultIndex', -1);
end;

function TConfig.GetLogFontSize: integer;
begin
  Result := ReadInteger('MAIN', 'logFontSize', 11);
end;

function TConfig.GetSplLeft: integer;
begin
  Result := ReadInteger('FORM', 'splLeft', 300);
end;

procedure TConfig.SetAutorunState(AValue: boolean);
begin
  WriteBool('MAIN', 'autorunState', AValue);
end;

procedure TConfig.SetFrmHeight(AValue: integer);
begin
  WriteInteger('FORM', 'height', AValue);
end;

procedure TConfig.SetFrmLeft(AValue: integer);
begin
  WriteInteger('FORM', 'left', AValue);
end;

procedure TConfig.SetFrmTop(AValue: integer);
begin
  WriteInteger('FORM', 'top', AValue);
end;

procedure TConfig.SetFrmWidth(AValue: integer);
begin
  WriteInteger('FORM', 'width', AValue);
end;

procedure TConfig.SetLatestVaultIndex(AValue: integer);
begin
  WriteInteger('MAIN', 'latestVaultIndex', AValue);
end;

procedure TConfig.SetLogFontSize(AValue: integer);
begin
  WriteInteger('MAIN', 'logFontSize', AValue);
end;

procedure TConfig.SetMountPoint(AValue: string);
begin
  WriteString('MAIN', 'mountPoint', AValue);
end;

procedure TConfig.SetMountPointShortName(AValue: boolean);
begin
  WriteBool('MAIN', 'mountPointShortName', AValue);
end;

procedure TConfig.SetSplLeft(AValue: integer);
begin
  WriteInteger('FORM', 'splLeft', AValue);
end;

end.
