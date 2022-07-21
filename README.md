<h1 align="center">
    <img src="icons/128x128.png" alt="gcencryptor_icon"/>
    <br>
    gcencryptor
    <br><br>
    <img src="https://helltar.com/projects/gcencryptor/screenshots/screenshot_19072022_160027.png" alt="gcencryptor_main"/>
</h1>

gcencryptor is a GUI for [gocryptfs](https://github.com/rfjakob/gocryptfs) so it needs a working gocryptfs [setup](https://github.com/rfjakob/gocryptfs#installation).

- https://youtu.be/A5GicX8CsmQ

Download
--------

- [gcencryptor-1.4.5_linux-qt-x86_64.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/v1.4.5/gcencryptor-1.4.5_linux-qt-x86_64.tar.gz) (1.57 MB)

Install the **qt5pas** library to run it:

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
sudo apt install libqt5pas1
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

The program does not save any sensitive data, like passwords, system logs, etc.

Available languages
-------------------
- English
- Ukrainian
- Russian

You can help translate:
- https://github.com/Helltar/gcencryptor/tree/master/locale

Build from source
-----------------

[![LazarusIDE](http://wiki.lazarus.freepascal.org/images/9/94/built_with_lazarus_logo.png)](http://www.lazarus-ide.org)
