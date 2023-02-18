# X jolemak layout

Colemak layout with minor alterations.

- special chars in original US-layout positions.
- q <-> j
- r <-> s
- \; -> o -> y -> ;
- *caps backspace* replaced by *left-control*

additionally, there are 'hidden keys'.

     alt-gr+(@) -> œ

     where @ is input and æ is the hidden key.


layout, jolemak:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       j w f p g q l u o y [ ] \
        a s r t d h n e i ; '
         z x c v b k m , . /

     (@, æ) = {  wå, aå, ;æ, 'ø, [«, ]», eé, ... }

layout, jolerus:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       я ш ф п г ч л у о ы [ ] \
        а с р т д х н е и ; '
         з ж ц в б к м , . /

     @ = { ф, у, ш, ,, ., и, е }
     œ = { э, ю, щ, ь, ъ, й, ё }

## In this repo

- readme with copy paste instructions to set up an exotic layout from a live-CD
- jolemak (based on colemak) for X.org (xkb symbols based on us/colemak)
- jolerus (based on jolemak) russian phonetic mapping of jolemak
- virtual terminal key map

## Using the layout

todo: add layout for grub, kernel initramfs

### X.org

    $ setxkbmap genja [jolemak]
    $ setxkbmap genja jolerus

### Virtual terminal

	$ loadkeys /usr/share/keymaps/i386/colemak/genja.map

## Installing the layout

    http://tinyurl.com/p9cw7lz
    =
    link to https://raw.githubusercontent.com
        /tox2ik/genja-jolemak/master/usr/share/X11/xkb/symbols/genja

copy & paste:

    (curl -L -k http://tinyurl.com/p9cw7lz ||
        wget http://tinyurl.com/p9cw7lz -O-) > /usr/share/X11/xkb/symbols/genja
    xset r rate 290 46
    setxkbmap genja -option terminate:ctrl_alt_bksp

### no root

use this when you cantwrite to /usr/share/X11/xkb

    xkbcomp -I$HOME/.xkb $HOME/.xkb/xkb-input $DISPLAY

### systemd

    localectl set-x11-keymap genja
    localectl set-keymap  genja

