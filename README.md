X jolemak layot 
===============

Colemak layout with minor alterations.  

- special chars in original US layot positions.
- q <-> j
- s <-> s
- \; -> o -> y -> ;

layout:

     j w f p g q l u o y [ ] \
      a s r t d h n e i ; '
       z x c v b k m , . /

In this repo:

- A couple of scripts to set up an exotic keyboard layout in live-CD.
- jolemak (based on colemak) for X.org (xkb symbols based on us/colemak)

Using the layout
------------------

    # X.org

    $ setxkbmap genja jolemak
    $ setxkbmap genja jolerus

    # Virtual terminal

	$ loadkeys /usr/share/keymaps/i386/colemak/genja.map

Installing the layout
---------------------
    
    wget http://tinyurl.com/p9cw7lz -O- > /usr/share/X11/xkb/symbols/genja
    curl -k https://raw.githubusercontent.com/tox2ik/genja-jolemak/master/usr/share/X11/xkb/symbols/genja > /usr/share/X11/xkb/symbols/genja
