X jolemak layout 
===============

Colemak layout with minor alterations.  

- special chars in original US-layout positions.
- q <-> j
- s <-> s
- \; -> o -> y -> ;

layout, jolemak:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       j w f p g q l u o y [ ] \
        a s r t d h n e i ; '
         z x c v b k m , . /

layout, jolerus:

    ` 1 2 3 4 5 6 7 8 9 0 - =
       я ш ф п г ч л у о ы [ ] \
        а с р т д х н е и ; '
         з ж ц в б к м , . /

    additionally, there are 'hidden keys' 

            alt-gr+(@) -> œ

     where @ = { ф, у, ш, ,, ., и, е }
       and œ = { э, ю, щ, ь, ъ, й, ё }

Also in this repo
-----------------

- jolemak (based on colemak) for X.org (xkb symbols based on us/colemak)
- jolerus (based on jolemak) russian phonetic mapping of jolemak
- virtual terminal key map
- A couple of commands to set up an exotic keyboard layout in a live-CD.


## Using the layout

todo: add layout for grub, kernel initramfs

### X.org

    $ setxkbmap genja jolemak
    $ setxkbmap genja jolerus

#### Virtual terminal

	$ loadkeys /usr/share/keymaps/i386/colemak/genja.map

## Installing the layout
    
    # link to https://raw.githubusercontent.com
    #     /tox2ik/genja-jolemak/master/usr/share/X11/xkb/symbols/genja 

    wget http://tinyurl.com/p9cw7lz -O- > /usr/share/X11/xkb/symbols/genja
    curl -L -k http://tinyurl.com/p9cw7lz > /usr/share/X11/xkb/symbols/genja
