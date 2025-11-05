# curl -skL https://raw.githubusercontent.com/tox2ik/genja-jolemak/refs/heads/master/install.sh | bash -x

o=/usr/share/X11/xkb/symbols/genja
uname -o | grep -qi bsd && o=/usr/local/share/X11/xkb/symbols/genja
curl -s -L -k http://tinyurl.com/p9cw7lz | sudo tee $o


xset r rate 290 46
setxkbmap genja -option terminate:ctrl_alt_bksp
