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
    function GetFrmLogHeight: integer;
    function GetFrmLogWidth: integer;
    function GetFrmTop: integer;
    function GetFrmWidth: integer;
    function GetLang: string;
    function GetLatestVaultIndex: integer;
    function GetLogFontSize: integer;
    function GetMountPoint: string;
    function GetMountPointShortName: boolean;
    function GetShowMenubar: boolean;
    function GetSplLeft: integer;
    procedure SetAutorunState(AValue: boolean);
    procedure SetFrmHeight(AValue: integer);
    procedure SetFrmLeft(AValue: integer);
    procedure SetFrmLogHeight(AValue: integer);
    procedure SetFrmLogWidth(AValue: integer);
    procedure SetFrmTop(AValue: integer);
    procedure SetFrmWidth(AValue: integer);
    procedure SetLang(AValue: string);
    procedure SetLatestVaultIndex(AValue: integer);
    procedure SetLogFontSize(AValue: integer);
    procedure SetMountPoint(AValue: string);
    procedure SetMountPointShortName(AValue: boolean);
    procedure SetShowMenubar(AValue: boolean);
    procedure SetSplLeft(AValue: integer);
  public
    constructor Create();
    property autorunState: boolean read GetAutorunState write SetAutorunState;
    property frmHeight: integer read GetFrmHeight write SetFrmHeight;
    property frmLeft: integer read GetFrmLeft write SetFrmLeft;
    property frmLogHeight: integer read GetFrmLogHeight write SetFrmLogHeight;
    property frmLogWidth: integer read GetFrmLogWidth write SetFrmLogWidth;
    property frmTop: integer read GetFrmTop write SetFrmTop;
    property frmWidth: integer read GetFrmWidth write SetFrmWidth;
    property lang: string read GetLang write SetLang;
    property latestVaultIndex: integer read GetLatestVaultIndex write SetLatestVaultIndex;
    property logFontSize: integer read GetLogFontSize write SetLogFontSize;
    property mountPoint: string read GetMountPoint write SetMountPoint;
    property mountPointShortName: boolean read GetMountPointShortName write SetMountPointShortName;
    property showMenubar: boolean read GetShowMenubar write SetShowMenubar;
    property splLeft: integer read GetSplLeft write SetSplLeft;
  end;

implementation

uses
  uConsts;

{ TConfig }

constructor TConfig.Create;
var
  configDir: string;

begin
  configDir := GetAppConfigDir(False);

  if not DirectoryExists(configDir) then
    mkDir(configDir);

  inherited Create(configDir + MAIN_CONF_FILE);
end;

function TConfig.GetMountPoint: string;
begin
  Result := ReadString('MAIN', 'mountPoint', GetAppConfigDir(False) + 'mnt');
end;

function TConfig.GetMountPointShortName: boolean;
begin
  Result := ReadBool('MAIN', 'mountPointShortName', False);
end;

function TConfig.GetShowMenubar: boolean;
begin
  Result := ReadBool('FORM', 'showMenubar', True);
end;

function TConfig.GetAutorunState: boolean;
begin
  Result := ReadBool('MAIN', 'autorunState', True);
end;

function TConfig.GetFrmHeight: integer;
begin
  Result := ReadInteger('FORM', 'height', 400);
end;

function TConfig.GetFrmLeft: integer;
begin
  Result := ReadInteger('FORM', 'left', 0);
end;

function TConfig.GetFrmLogHeight: integer;
begin
  Result := ReadInteger('FORM', 'logHeight', 350);
end;

function TConfig.GetFrmLogWidth: integer;
begin
  Result := ReadInteger('FORM', 'logWidth', 800);
end;

function TConfig.GetFrmTop: integer;
begin
  Result := ReadInteger('FORM', 'top', 0);
end;

function TConfig.GetFrmWidth: integer;
begin
  Result := ReadInteger('FORM', 'width', 600);
end;

function TConfig.GetLang: string;
begin
  Result := ReadString('MAIN', 'lang', 'en');
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
  Result := ReadInteger('FORM', 'splLeft', 200);
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

procedure TConfig.SetFrmLogHeight(AValue: integer);
begin
  WriteInteger('FORM', 'logHeight', AValue);
end;

procedure TConfig.SetFrmLogWidth(AValue: integer);
begin
  WriteInteger('FORM', 'logWidth', AValue);
end;

procedure TConfig.SetFrmTop(AValue: integer);
begin
  WriteInteger('FORM', 'top', AValue);
end;

procedure TConfig.SetFrmWidth(AValue: integer);
begin
  WriteInteger('FORM', 'width', AValue);
end;

procedure TConfig.SetLang(AValue: string);
begin
  WriteString('MAIN', 'lang', AValue);
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

procedure TConfig.SetShowMenubar(AValue: boolean);
begin
  WriteBool('FORM', 'showMenubar', AValue);
end;

procedure TConfig.SetSplLeft(AValue: integer);
begin
  WriteInteger('FORM', 'splLeft', AValue);
end;

end.
