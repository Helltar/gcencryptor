gcencryptor
===========

gcencryptor is a GUI for [gocryptfs](https://github.com/rfjakob/gocryptfs) so it needs a working gocryptfs [setup](https://github.com/rfjakob/gocryptfs#installation).

- https://youtu.be/A5GicX8CsmQ

<p align="center">
  <img src="https://helltar.com/projects/gcencryptor/screenshots/screenshot_13072022_184026.png" alt="gcencryptor_linux_qt"/>
</p>

Download
--------

- [gcencryptor-1.4.2_linux-qt-x86_64.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/v1.4.2/gcencryptor-1.4.2_linux-qt-x86_64.tar.gz) (1.3 MB)

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
