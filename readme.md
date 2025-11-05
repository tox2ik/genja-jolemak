# Jolemak Keyboard layout

Essentially, this is a fork of the the [colemak layout](https://colemak.com),
with some minor alterations.


- special chars ([], {}, ()) reverted to original US-layout positions
  - i believe those positions were created by programes for programmers in the 1980s
  - this is vastly superior to any european layout I have used for those keys
- caps
    - backspace -> left-control
- alterations to semicolon, wovels & consensenats:
    - q <-> j
    - r <-> s
    - \; -> o -> y -> ;

## In this repo

- readme with copy paste instructions to set up an exotic layout (from a live-CD)
- jolemak (based on colemak) for X.org (xkb symbols based on us/colemak)
- jolerus (based on jolemak) russian phonetic mapping of jolemak
- jolemak.klc source file for Microsoft Keyboard Layout Creator
- binary installer for windows 7..11 (and later? could work on xp too)
- virtual console key map

## Installing the layout

copy & paste from a live-cd:

  
    curl -skL https://raw.githubusercontent.com/tox2ik/genja-jolemak/refs/heads/master/install.sh | bash -x

    if [[ ! -f /usr/share/X11/xkb/symbols/genja ]]; then
        (curl -L -k http://tinyurl.com/p9cw7lz \
            || wget http://tinyurl.com/p9cw7lz -O-) \
            | sudo tee /usr/share/X11/xkb/symbols/genja | wc -c
    fi
    xset r rate 290 46
    setxkbmap genja -option terminate:ctrl_alt_bksp


the xorg-map file:

    $ curl http://tinyurl.com/p9cw7lz
    =
    link to https://raw.githubusercontent.com
        /tox2ik/genja-jolemak/master/usr/share/X11/xkb/symbols/genja


### layout, jolemak:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       j w f p g q l u o y [ ] \
        a s r t d h n e i ; '
         z x c v b k m , . /

     (@, æ) = { yå, aä, ;æ, 'ø, [«, ]», sß, oö, uü, ... }

- ![jolemak](/image/jolemak.jpg "Jolemak")

With <kdb>Alt-Gr</kbd>: 

- ![jolemak altgr](/image/jolemak-AltGr.jpg "Jolemak Alternative Graph")

additionally, there are 'hidden keys'.

     alt-gr+(@) -> œ

     where @ is input and æ is the hidden key.


### layout, jolerus:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       я ш ф п г ч л у о ы [ ] \
        а с р т д х н е и ; '
         з ж ц в б к м , . /

     @ = { ф, у, ш, ,, ., и, е }
     œ = { э, ю, щ, ь, ъ, й, ё }


### no root

use this when you cantwrite to /usr/share/X11/xkb

    xkbcomp -I$HOME/.xkb $HOME/.xkb/xkb-input $DISPLAY


## Using the layout

todo: add layout for grub2

### X.org

    $ setxkbmap genja [jolemak]
    $ setxkbmap genja jolerus

### Virtual console

	$ loadkeys /usr/share/keymaps/i386/colemak/genja.map

### Systemd

    $ localectl set-x11-keymap genja
    $ localectl set-keymap genja

### Initramfs

Add the binary layout to the ram-fs and load it with busybox `loadkmap`.

    $ loadkeys -b genja.map > initramfs-overlay/jolemak.bmap
    $ loadkmap < jolemak.bmap

### Windows

Install from the provided binary and chose the "us - jolemak" variety in settings - regional settings.

    
### Mac OS

Use `Ukelele_3.30.dmg` to create or modify layouts on mac os

