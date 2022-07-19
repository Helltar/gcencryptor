<h1 align="center">
    <img src="icons/128x128.png" alt="gcencryptor_icon"/>
    <br>
    gcencryptor
    <br><br>
    <img src="https://helltar.com/projects/gcencryptor/screenshots/screenshot_19072022_160027.png" alt="gcencryptor_main"/>
</h1>

gcencryptor is a GUI for [gocryptfs](https://github.com/rfjakob/gocryptfs) so it needs a working gocryptfs [setup](https://github.com/rfjakob/gocryptfs#installation).

Download
--------

- [gcencryptor-1.5.0.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/1.5.0/gcencryptor-1.5.0.tar.gz) (1.65 MB)
- [gcencryptor-1.5.0.tar.gz.sha256sum](https://helltar.com/projects/gcencryptor/bin/sha256sums/gcencryptor-1.5.0.tar.gz.sha256sum)

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

Third-party components:

- [UniqueInstance](https://github.com/blikblum/luipack/releases/tag/uniqueinstance-1.1)
