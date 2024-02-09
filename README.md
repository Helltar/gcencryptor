<h3 align="center">
    <img src="icons/gcencryptor.svg" height="96" alt="gcencryptor_icon"/>
    <br><br>
    gcencryptor is a GUI for <a href="https://github.com/rfjakob/gocryptfs">gocryptfs</a>
    <br><br>
    <img src="https://helltar.com/projects/gcencryptor/screenshots/screenshot_26072022_125437.png" alt="gcencryptor_main_window"/>
    <br><br>
    <a href="https://youtu.be/TZnUgkd3Ki0">youtu.be/TZnUgkd3Ki0</a>
</h3>

Download
--------

- [gcencryptor-1.5.4.tar.gz](https://github.com/Helltar/gcencryptor/releases/download/1.5.5/gcencryptor-1.5.5.tar.gz) (1.64 MB)

Installation
------------

NOTE: **Arch** users can just install **gcencryptor** from the **AUR**: ([gcencryptor](https://aur.archlinux.org/packages/gcencryptor)) and skip next section.

Dependencies:

**Arch Linux**:

```
sudo pacman -S gocryptfs qt5pas
```

**Ubuntu**:

```
sudo apt install gocryptfs libqt5pas1
```

Usage
-----

Unpack and run:

```
cd ~/Downloads/
```
```
tar -xvf gcencryptor-1.5.5.tar.gz
```
```
cd gcencryptor/ && ./gcencryptor
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
- Spanish

You can help translate:
- https://github.com/Helltar/gcencryptor/tree/master/locale

Build from source
-----------------

[![LazarusIDE](http://wiki.lazarus.freepascal.org/images/9/94/built_with_lazarus_logo.png)](http://www.lazarus-ide.org)

Wiki
----

- [Tips & Tricks](https://github.com/Helltar/gcencryptor/wiki/Tips-&-Tricks)
- [Keyboard Shortcuts](https://github.com/Helltar/gcencryptor/wiki/Keyboard-Shortcuts)
