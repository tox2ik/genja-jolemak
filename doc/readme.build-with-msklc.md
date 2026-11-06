# Build the layout with MSKLC

The source is `opt/jolemak/jolemak.2026.klc` (UTF-16 text). Microsoft
Keyboard Layout Creator (MSKLC) 1.4 turns it into the layout DLLs and an
installer.

1. `make msklc` installs MSKLC 1.4 (downloads it to `opt/msklc/` and checks
   the signature). Once only.
2. `make msklc-run` starts it. File > Load Source File, pick
   `opt/jolemak/jolemak.2026.klc`.
3. Project > Validate Layout. The log goes to `Documents\KeyboardVerify.log`.
   Warnings about redundant or duplicate control characters, and about Caps
   Lock on A I O P, are expected (see
   [readme.fix-control-characters.md](readme.fix-control-characters.md)).
   Errors are not.
4. Project > Build DLL and Setup Package. Output goes to
   `Documents\jolemak3\` (named after `KBD` in the klc):
   - `setup.exe` and `jolemak3_{amd64,i386,ia64}.msi`
   - `amd64\`, `i386\`, `ia64\`, `wow64\`, each holding `jolemak3.dll`
5. `make package` zips that folder as `winders/jolemak-2026.zip`, with a
   top folder `jolemak-2026/` like `jolemak-2019.zip`.
6. `make install` unpacks the newest `winders/jolemak-*.zip` and runs its
   `*_amd64.msi` silently (one UAC prompt unless make runs elevated), then
   sign out. It skips a layout whose DLL is already registered. It installs
   next to the 2019 layout; `make uninstall-2019` removes the old one.
7. `make clean` removes `opt/msklc/MSKLC.exe`, the log,
   `Documents\jolemak3\` (kept until `make package` has made the zip) and
   unpacked `winders/jolemak-*/` folders that have a zip next to them.

Notes:

- Saving in MSKLC rewrites the klc: it resets `VERSION` to 1.0 and fills in
  the comments. Check `git diff` after a save.
- A rebuild with the same `KBD` name needs the old build uninstalled first
  and a sign-out; Windows keeps the loaded DLL until then.
