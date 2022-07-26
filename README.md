<h1 align="center">
    <img src="icons/512x512.png" width="128" height="128" alt="gcencryptor_icon"/>
    <br>
    gcencryptor
    <br><br>
    <img src="https://helltar.com/projects/gcencryptor/screenshots/screenshot_26072022_125437.png" alt="gcencryptor_main"/>
</h1>

gcencryptor is a GUI for [gocryptfs](https://github.com/rfjakob/gocryptfs) so it needs a working gocryptfs [setup](https://github.com/rfjakob/gocryptfs#installation).

Download
--------

- [gcencryptor-1.5.1.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/1.5.1/gcencryptor-1.5.1.tar.gz) (1.66 MB)
- [gcencryptor-1.5.1.tar.gz.sha256sum](https://helltar.com/projects/gcencryptor/bin/sha256sums/gcencryptor-1.5.1.tar.gz.sha256sum)

Install
-------

Dependencies:

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

Unpack and run:

```
cd ~/Downloads/
```
```
tar -xvzf gcencryptor-1.5.1.tar.gz
```
```bash
sudo mv gcencryptor/ /opt/ # you can use any other directory
```
```
/opt/gcencryptor/gcencryptor
```

To make available in your list of applications, got to **Settings** > **Create Desktop Entry**.

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

Wiki
----

- [Tips & Tricks](https://github.com/Helltar/gcencryptor/wiki/Tips-&-Tricks)
- [Keyboard Shortcuts](https://github.com/Helltar/gcencryptor/wiki/Keyboard-Shortcuts)
