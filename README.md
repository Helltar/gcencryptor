gcencryptor
===========

gcencryptor is a GUI for [gocryptfs](https://github.com/rfjakob/gocryptfs) so it needs a working gocryptfs [setup](https://github.com/rfjakob/gocryptfs#installation).

- https://youtu.be/6NEIftu0ke8

![gcencryptor_linux_qt](https://helltar.com/projects/gcencryptor/screenshots/screenshot_30062022_061157.png)

Download
--------

- [gcencryptor-1.3.0_linux-qt-x86_64.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/v1.3/gcencryptor-1.3.0_linux-qt-x86_64.tar.gz) (1.25 MB)

Install
-------

*GUI* gcencryptor uses **Qt**, install the **qt5pas** library to run it:

**Arch Linux**:

```
sudo pacman -S qt5pas
```

**Fedora**:

```
sudo dnf install qt5pas
```

**Ubuntu**:

```
sudo apt install libqt5pas-dev
```

Usage
-----

Unpack to any directory and run (the program is native):

```
./gcencryptor
```

Configuration stored in:

```
~/.config/gcencryptor/
```

Build from source
-----------------

[![LazarusIDE](http://wiki.lazarus.freepascal.org/images/9/94/built_with_lazarus_logo.png)](http://www.lazarus-ide.org)
