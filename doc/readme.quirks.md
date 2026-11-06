# Layout quirks

Deliberate oddities in the jolemak klc files (`opt/jolemak/*.klc`). MSKLC
drops custom comments when it saves a klc, so they are noted here instead.

## en-CA locale with en-US names

`LOCALENAME` / `LOCALEID` are en-CA (`1009`), but `DESCRIPTIONS` and
`LANGUAGENAMES` are under `0409` (English, United States). This is on
purpose: it makes Windows list jolemak under English (Canada), apart from the
plain en-US layouts, so the switcher shows en-CA = jolemak and en-US = QWERTY.
The installed layout ID ends in `1009` for the same reason (`A0001009`,
`A0011009`).

## Å on the QWERTY `[` position

Shift+AltGr on the QWERTY `[` position types Å, the same as Shift+AltGr on
the QWERTY P position (jolemak `y`). Not a mistake: Å sits on that key on a
Norwegian keyboard.
