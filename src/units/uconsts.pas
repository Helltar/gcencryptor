unit uConsts;

{$mode ObjFPC}{$H+}

interface

const
  APP_NAME = 'gcencryptor';

  FUSERMOUNT_BIN = 'fusermount';
  FUSER_BIN = 'fuser';
  GOCRYPTFS_BIN = 'gocryptfs';
  GOCRYPTFS_XRAY_BIN = 'gocryptfs-xray';

  MAIN_CONF_FILENAME = 'config';
  VAULTLIST_CONF_FILENAME = 'vaultlist';
  GOCRYPTFS_CONF_FILENAME = 'gocryptfs.conf';

  URL_HOMEPAGE = 'https://helltar.com';
  URL_GCENCRYPTOR = 'https://github.com/Helltar/gcencryptor';
  URL_GOCRYPTFS = 'https://github.com/rfjakob/gocryptfs';
  URL_PAPIRUS = 'https://github.com/PapirusDevelopmentTeam/papirus-icon-theme';

  KDE_DESKTOP = 'KDE';
  GNOME_DESKTOP = 'GNOME';

resourcestring
  {$I strings.inc}

implementation

end.
