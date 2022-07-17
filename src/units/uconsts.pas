unit uConsts;

{$mode ObjFPC}{$H+}

interface

const
  FUSERMOUNT_BIN = 'fusermount';
  FUSER_BIN = 'fuser';
  GOCRYPTFS_BIN = 'gocryptfs';
  GOCRYPTFS_XRAY_BIN = 'gocryptfs-xray';

  MAIN_CONF_FILE = 'config';
  VAULTLIST_CONF_FILE = 'vaultlist';
  GOCRYPTFS_CONF_FILE = 'gocryptfs.conf';

  URL_HOMEPAGE = 'https://helltar.com';
  URL_GCENCRYPTOR = 'https://github.com/Helltar/gcencryptor';
  URL_GOCRYPTFS = 'https://github.com/rfjakob/gocryptfs';
  URL_PAPIRUS = 'https://github.com/PapirusDevelopmentTeam/papirus-icon-theme';

resourcestring
  {$I strings.inc}

implementation

end.
