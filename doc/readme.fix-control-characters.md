# Ctrl + letter sends QWERTY control characters under jolemak

This repo is checked out at `~/ws/genja-jolemak`
(`C:\Users\jazzo\ws\genja-jolemak`). The Windows setup repo that installs
the layout is `C:\_setup.new\setup-2026-cut`.

## Terms

- **QWERTY position**: a physical key, named by the letter it has on a US
  QWERTY keyboard. In the klc this is the VK column (`VK_Q`, `VK_E`, ...).
- **jolemak letter**: the letter that key types under jolemak.

Example: the key at QWERTY position Q types the jolemak letter `j`.

## The problem

With the jolemak layout on Windows, Ctrl + a letter in a terminal sends the
control character of the QWERTY position, not of the jolemak letter.

- Ctrl + QWERTY position Q (types `j`) sends ^Q (0x11, XON) instead of ^J
  (0x0A, line feed).
- Ctrl + QWERTY position K (types `e`) sends ^K instead of ^E, so "end of
  line" in bash/readline needs the key at QWERTY position E, which types `f`.
- The same goes for Ctrl+Shift+letter, and for Ctrl+Alt+letter (Esc +
  control character).

These are control characters, not scan codes. The scan code (the physical
key) is correct; the character Windows makes from it is the wrong one.

Affected keys (jolemak letter differs from the QWERTY position):

| QWERTY position | Q | E | R | T | Y | U | I | P | D | F | G | J | K | L | N |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| jolemak letter | j | f | p | g | q | l | u | y | r | t | d | n | e | i | k |

The other 11 letters (A S H O W Z X C V B M) are on the same key in both,
so Ctrl already sends the right character for them.

## Cause: the layout file

`opt/jolemak/jolemak.2019.klc`:

```
//SC  VK_  Cap  0  1  2   6     7
10    Q    1    j  J  -1  -1    -1
```

- The VK column (`Q`) keeps the QWERTY position for every letter key.
- The Ctrl column (shift state `2`) is `-1` (none) for all letters.

When a layout gives no Ctrl character, the control character is derived from
the VK, so VK_Q gives ^Q. Windows Terminal passes on that character; a
maintainer closed this as a layout issue
([microsoft/terminal#13319](https://github.com/microsoft/terminal/issues/13319),
[#4885](https://github.com/microsoft/terminal/issues/4885)).
The klc already fills the Ctrl column for `[` (`001b`, Esc), `]` and `\`,
so the mechanism works; the letters were just never filled in.

## Current workaround

In the setup repo, `config/terminal/settings.jolemak.workaroundmaps.json` is
merged into Windows Terminal by `make terminal`: 45 `sendInput` key bindings.

- Ctrl and Ctrl+Shift on the 15 keys above, plus Ctrl+A/S/H sending themselves.
- Ctrl+Alt on 12 of them. Not on QWERTY positions I, P, J, where AltGr
  (= Ctrl+Alt) types ü å ✗.
- Ctrl+Shift+T/P/F/D/N take over Terminal's new tab, command palette, find,
  duplicate tab and new window.
- Windows Terminal only. Other apps and terminals still get QWERTY
  control characters.

## Other terminals (research, read from source and issues, not tested)

| Terminal | Layout-aware Ctrl characters? | Remapping | AltGr vs Ctrl+Alt |
|---|---|---|---|
| Windows Terminal | No: uses the char Windows supplies (^Q here); no setting | `sendInput`, one binding per key + modifiers | skips bindings while AltGr is down ([GH#2235](https://github.com/microsoft/terminal/blob/main/src/cascadia/TerminalControl/TermControl.cpp)) |
| WezTerm | Yes: clears Ctrl, calls `ToUnicode`, applies Ctrl itself | `keys` table, `mapped:` / `phys:`, `key_map_preference` | detected; `treat_left_ctrlalt_as_altgr` |
| mintty (Git Bash window) | Likely yes: `ToUnicode` with Ctrl cleared, then `CTRL(wc)` | `KeyFunctions=` one-line list | `CtrlAltIsAltGr`, `AltGrIsAlsoAlt` |
| Alacritty, Rio | Likely no (winit text = WM_CHAR) | bindings match the typed letter: `{key="j", mods="Control", chars="\n"}` | workaround in code, unverified |
| Tabby, Hyper, ConEmu | Probably no (unverified) | hotkeys / plugins / macros | Tabby has AltGr bugs |

Sources: [terminalInput.cpp](https://github.com/microsoft/terminal/blob/main/src/terminal/input/terminalInput.cpp),
[WezTerm window.rs](https://github.com/wezterm/wezterm/blob/main/window/src/os/windows/window.rs),
[key_map_preference](https://wezterm.org/config/lua/config/key_map_preference.html),
[mintty wininput.c](https://github.com/mintty/mintty/blob/master/src/wininput.c),
[Alacritty keyboard.rs](https://github.com/alacritty/alacritty/blob/master/alacritty/src/input/keyboard.rs),
[Kaplan on Ctrl chars](https://archives.miloush.net/michkap/archive/2006/04/18/578557.html).

## Options

There are two separate things on every key: the **control character** (what
a terminal receives) and the **VK** (what GUI apps match shortcuts against).
The options differ in which of the two follows the jolemak letter.

### 1. Fill the Ctrl column in the klc (recommended)

The control character follows the jolemak letter; the VK stays the QWERTY
position.

- Terminals: Ctrl + QWERTY position Q (types `j`) sends ^J (0x0A).
  Ctrl + QWERTY position K (types `e`) sends ^E, so readline's end-of-line
  is on the key that types `e`. Works in every terminal, with no bindings.
- GUI apps: shortcuts stay on their QWERTY positions, because apps match
  them by VK, which does not change. Ctrl+S (save) in Notepad is still
  QWERTY position S, Ctrl+F (find) is still QWERTY position F (which types
  `t`), Ctrl+T (new tab) in a browser is still QWERTY position T (types `g`).
- This is the behaviour you have today in GUI apps, so nothing moves there.

### 2. Change the VKs to the jolemak letters

Like Microsoft's own Dvorak layout: row `10 Q ...` becomes `10 J ...`.
Both the control character and the VK follow the jolemak letter.

- Terminals: same as option 1, Ctrl + the key that types `j` sends ^J.
- GUI apps: every shortcut moves to the key that types its letter.

| Shortcut | Today: QWERTY position | Option 2: QWERTY position |
|---|---|---|
| Ctrl+F find | F | E |
| Ctrl+T new tab | T | F |
| Ctrl+P print | P | R |
| Ctrl+R reload | R | D |
| Ctrl+D bookmark / duplicate | D | G |
| Ctrl+N new window | N | J |
| Ctrl+L address bar | L | U |
| Ctrl+E search / end of line | E | K |
| Ctrl+Y redo | Y | P |
| Ctrl+K | K | N |

- Ctrl+Z X C V (undo, cut, copy, paste), Ctrl+A (select all), Ctrl+S
  (save), Ctrl+W (close tab) and Ctrl+O, H, B, M do not move: those letters
  are on the same key in QWERTY and jolemak.
- Games and apps that read keys by VK (WASD and so on) also see the
  jolemak letters.

### 3. Leave the layout, change terminal

Keep the klc as it is and use a terminal that works the control character
out from the typed letter itself.

- WezTerm: on Ctrl + QWERTY position Q it clears Ctrl, asks Windows which
  letter the key types (`j`), and sends ^J. Same result as option 1, but
  only in WezTerm.
- mintty (the Git Bash window): reads the source as doing the same
  (`ToUnicode` with Ctrl cleared, then Ctrl applied). Not tested.
- Windows Terminal keeps sending ^Q unless the `sendInput` bindings stay.
- GUI apps are unaffected either way.

## Proposed changes (option 1)

The changes are made in `opt/jolemak/jolemak.2026.klc`, a copy of
`jolemak.2019.klc` (left as is). It also bumps `VERSION` to 1.1 and the
copyright to 2013-2026. Not built or tested yet.

### 1. Ctrl column

Columns: SC VK Cap, then shift states 0 1 2 6 7 (comments dropped).

```diff
-10 Q 1 j J -1 -1 -1
+10 Q 1 j J 000a -1 -1
-12 E 1 f F -1 -1 -1
+12 E 1 f F 0006 -1 -1
-13 R 1 p P -1 -1 1f355
+13 R 1 p P 0010 -1 1f355
-14 T 1 g G -1 -1 -1
+14 T 1 g G 0007 -1 -1
-15 Y 1 q Q -1 -1 -1
+15 Y 1 q Q 0011 -1 -1
-16 U 1 l L -1 -1 -1
+16 U 1 l L 000c -1 -1
-17 I 5 u U -1 00fc 00dc
+17 I 5 u U 0015 00fc 00dc
-19 P 5 y Y -1 00e5 00c5
+19 P 5 y Y 0019 00e5 00c5
-20 D 1 r R -1 -1 -1
+20 D 1 r R 0012 -1 -1
-21 F 1 t T -1 -1 -1
+21 F 1 t T 0014 -1 -1
-22 G 1 d D -1 -1 -1
+22 G 1 d D 0004 -1 -1
-24 J 1 n N -1 2717 1f6ab
+24 J 1 n N 000e 2717 1f6ab
-25 K 1 e E -1 -1 -1
+25 K 1 e E 0005 -1 -1
-26 L 5 i I -1 -1 -1
+26 L 5 i I 0009 -1 -1
-31 N 1 k K -1 -1 -1
+31 N 1 k K 000b -1 -1
```

The other letters (A S H O W Z X C V B M) are on their QWERTY positions, so
the VK fallback already gives the right character. Filling their Ctrl
column too (and ^@ ^^ ^_ on Ctrl+Shift+2, Ctrl+Shift+6, Ctrl+-) is
proposed, pending review, so the layout does not depend on the fallback.

### 2. Ctrl+Shift

Add shift state 3 (Shift+Ctrl) after 2 in `SHIFTSTATE`:

```
SHIFTSTATE
0	//Column 4
1	//Column 5 : Shft
2	//Column 6 :       Ctrl
3	//Column 7 : Shft  Ctrl
6	//Column 8 :       Ctrl Alt
7	//Column 9 : Shft  Ctrl Alt
```

Every `LAYOUT` row then has a value in the new column, after the Ctrl one:
a copy of the Ctrl column, so the 15 keys above get their jolemak control
character and `[` `]` `\` Space keep theirs under Shift+Ctrl too.

### 3. Ctrl+Alt (not proposed yet)

Shift state 6 is AltGr, which already types ü å ✗ etc., so it cannot also
carry Esc + control character. Keep Ctrl+Alt remaps in the terminal for
now, and check what Windows Terminal sends for left Ctrl+Alt+key once 1 and
2 are in.

### 4. Caps Lock on ø and æ

ü ö å ä (QWERTY positions I O P A) have `Cap 5`, so Caps Lock also
capitalizes them on AltGr. ø and æ (QWERTY positions `;` and `'`) had
`Cap 0`, so Caps Lock gave ø, not Ø. They get `Cap 4` (Caps Lock affects
AltGr only), so Caps Lock + AltGr gives Ø Æ and `;` `'` are unchanged.

### 5. Name and locale

- The layout is renamed: `KBD jolemak3` (was `jolemak2`), so it builds
  `jolemak3.dll` and `jolemak3_amd64.msi`. The description shown in the
  Windows input switcher is "Jolemak 2026" (was "Colemak US-NO"); the MSI
  shows up in Apps as "Colemak variant by Jaroslav R.".
- The locale is en-CA (`LOCALEID 00001009`) while `DESCRIPTIONS` and
  `LANGUAGENAMES` use `0409`. This is deliberate: it keeps the layout
  listed separately from a plain en-US layout in the Windows UI.

### 6. Build and install

- `make msklc` installs MSKLC 1.4. It is not on winget; the installer is
  downloaded from Microsoft to `opt/msklc/` (gitignored) and its signature
  checked.
- MSKLC: open `jolemak.2026.klc`, Project > Build DLL and Setup Package.
  Package it as `winders/jolemak-2026.zip` next to the 2019 one (it holds
  `jolemak3_amd64.msi`).
- Because of the new name, the 2026 layout installs next to the 2019 one
  (`jolemak2.dll`, KLID `A0001009`). No need to uninstall first, and no DLL
  cache problem, since the DLL name differs.
- The KLID is assigned at install time: the first free `A0xx1009`. A fresh
  system gets `A0001009`; a system that still has the 2019 layout gets the
  next one, likely `A0011009`.
- `make uninstall-2019` removes the old layout later (asks first, runs its
  MSI uninstall).

### 7. Setup repo (`C:\_setup.new\setup-2026-cut`)

- `features/keyboard.ps1` checks for the fixed KLID `A0001009`, so it would
  see the old layout and never install the new one. Change it to:
  - find the layout by `Layout File` = `jolemak3.dll` under
    `HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts`, and install
    when none is found;
  - download `winders/jolemak-2026.zip` and look for `jolemak3_amd64.msi`;
  - use the KLID it found in the language list (`1009:<KLID>`).
- The language list sets exactly one layout for en-CA, so the 2019 layout
  stays installed but leaves the switcher.
- Delete `config/terminal/settings.jolemak.workaroundmaps.json` and run
  `make terminal`; actions and key bindings are replaced by the repo set,
  so the remaps go, and Terminal's Ctrl+Shift+T/P/F/D/N come back.

### Risks (untested)

- Some Win32 controls act on the WM_CHAR control character rather than the
  VK (for example a control that treats 0x01 as select-all). Those would
  now follow the jolemak letter. Shortcuts handled by VK (menus,
  accelerators, most apps) are unaffected.
- The VK stays the QWERTY position, so apps that read Ctrl+key by VK
  (Windows Terminal's own key bindings, games, many editors) behave as
  today.
