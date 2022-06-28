unit uMountList;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TMountList }

  TMountList = class(TStringList)
  private
    function isVaultExists(const vault: string): boolean;
  public
    function getMountPoint(const index: integer): string;
    function getMountPoint(const vault: string): string;
    function getSize(): integer;
    function getVaultDir(const index: integer): string;
    function isListNotEmpty(): boolean;
    procedure add(const vault, mountpoint: string);
    procedure del(const index: integer);
    procedure del(const vault: string);
  end;

implementation

{ TMountList }

function TMountList.isVaultExists(const vault: string): boolean;
begin
  Result := isListNotEmpty() and (IndexOfName(vault) <> -1);
end;

function TMountList.isListNotEmpty: boolean;
begin
  Result := Count > 0;
end;

function TMountList.getVaultDir(const index: integer): string;
begin
  Result := '';

  if isListNotEmpty() then
    Result := Names[index];
end;

function TMountList.getMountPoint(const vault: string): string;
begin
  Result := '';

  if isVaultExists(vault) then
    Result := Values[vault];
end;

function TMountList.getMountPoint(const index: integer): string;
begin
  Result := '';

  if isListNotEmpty() then
    Result := ValueFromIndex[index];
end;

function TMountList.getSize: integer;
begin
  Result := Count - 1; // for loop statement
end;

procedure TMountList.add(const vault, mountpoint: string);
begin
  AddPair(vault, mountpoint);
end;

procedure TMountList.del(const vault: string);
begin
  if isVaultExists(vault) then
    Delete(IndexOfName(vault));
end;

procedure TMountList.del(const index: integer);
begin
  if isListNotEmpty() then
    Delete(index);
end;

end.
