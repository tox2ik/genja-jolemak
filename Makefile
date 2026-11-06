# Build and install the jolemak Windows layout. Recipes run in pwsh (native Windows GNU make).
# Start with:  make help
#
# Long recipes span lines with ' #\': make passes the newline on to pwsh, which
# reads '#\' as a comment, so it stays one pwsh process (variables carry over).

SHELL         := pwsh.exe
.SHELLFLAGS   := -NoProfile -NoLogo -Command
.DEFAULT_GOAL := help

# MSKLC 1.4 is not on winget; this is Microsoft's own download (gitignored).
MSKLC_URL   := https://download.microsoft.com/download/6/f/5/6f5ce43a-e892-4fd1-b9a6-1a0cbb64e6e2/MSKLC.exe
MSKLC_EXE   := C:/Program Files (x86)/Microsoft Keyboard Layout Creator 1.4/MSKLC.exe
MSKLC_SETUP := opt/msklc/MSKLC.exe

# MSKLC builds into Documents\<KBD name>\ and logs Validate Layout to
# Documents\KeyboardVerify.log. `package` zips that build as winders/<PACKAGE>.zip
# with one top folder <PACKAGE>/, like jolemak-2019.zip.
BUILD_NAME := jolemak3
PACKAGE    := jolemak-2026
DOCS       := ([Environment]::GetFolderPath('MyDocuments'))

# The installed 2019 layout: its MSI's DisplayName (= the KBD description in its klc).
OLD_NAME := Colemak version by Jaroslav

# pwsh snippets
layouts  = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts' | Get-ItemProperty
products = Get-ItemProperty -ErrorAction Ignore 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
# msiexec with the arguments in $$a, elevated (no UAC prompt if the shell already is).
msiexec  = $$r = Start-Process msiexec.exe -Verb RunAs -Wait -PassThru -ArgumentList $$a; if ($$r.ExitCode -notin 0, 1641, 3010) { Write-Error "msiexec failed: $$($$r.ExitCode)"; exit 1 }

##@ build

msklc-download: ## download the MSKLC 1.4 installer to opt/msklc/ and check its signature
	@if (-not (Test-Path '$(MSKLC_SETUP)')) { #\
	  New-Item -ItemType Directory -Force opt/msklc | Out-Null #\
	  Invoke-WebRequest '$(MSKLC_URL)' -OutFile '$(MSKLC_SETUP)' #\
	} #\
	$$s = Get-AuthenticodeSignature '$(MSKLC_SETUP)' #\
	if ($$s.Status -ne 'Valid' -or $$s.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') { #\
	  Write-Error "bad signature: $$($$s.Status) $$($$s.SignerCertificate.Subject)"; exit 1 #\
	} #\
	Get-Item '$(MSKLC_SETUP)' | Format-Table Name, Length, LastWriteTime

msklc: msklc-download ## install Microsoft Keyboard Layout Creator 1.4 (not on winget)
	@if (Test-Path '$(MSKLC_EXE)') { 'MSKLC 1.4 is already installed'; exit } #\
	$$find = { Get-ChildItem opt/msklc -Recurse -Filter MSKLC.msi | Select-Object -First 1 } #\
	if (-not ($$msi = & $$find)) { #\
	  'MSKLC.exe only unpacks: pick opt\msklc as the folder' #\
	  Start-Process '$(MSKLC_SETUP)' -Wait #\
	  if (-not ($$msi = & $$find)) { Write-Error 'MSKLC.msi not found under opt/msklc'; exit 1 } #\
	} #\
	$$a = '/i', ('"{0}"' -f $$msi.FullName), '/qb' #\
	$(msiexec) #\
	"installed: $$(Test-Path '$(MSKLC_EXE)')"

msklc-run: ## start MSKLC with this folder as its working directory
	@if (-not (Test-Path '$(MSKLC_EXE)')) { Write-Error 'MSKLC 1.4 is not installed: make msklc'; exit 1 } #\
	Start-Process '$(MSKLC_EXE)' -WorkingDirectory '$(CURDIR)'

package: ## zip the MSKLC build from Documents into winders/, like the 2019 zip
	@$$src = Join-Path $(DOCS) '$(BUILD_NAME)' #\
	if (-not (Test-Path "$$src/$(BUILD_NAME)_amd64.msi")) { #\
	  Write-Error "no build in $${src}: in MSKLC, Project > Build DLL and Setup Package"; exit 1 #\
	} #\
	$$tmp = New-Item -ItemType Directory -Force (Join-Path ([IO.Path]::GetTempPath()) "jolemak-package-$$PID") #\
	Copy-Item -Recurse $$src "$$tmp/$(PACKAGE)" #\
	$$zip = '$(CURDIR)/winders/$(PACKAGE).zip'; $$tar = "$$env:SystemRoot\System32\tar.exe" #\
	Remove-Item -Force -ErrorAction Ignore $$zip #\
	& $$tar -a -cf $$zip -C $$tmp '$(PACKAGE)'; $$code = $$LASTEXITCODE #\
	Remove-Item -Recurse -Force $$tmp #\
	if ($$code) { exit $$code } #\
	& $$tar -tf $$zip

##@ install

install: install-msi ## install the newest layout in winders/ and make it the default
	@$(MAKE) --no-print-directory use-latest

# Newest zip by name (jolemak-2026 > jolemak-2019), unpacked to winders/<name>/.
# /qn shows no dialogs, so the UAC prompt is the one click left.
install-msi: ## install the newest layout in winders/ silently, skip if its DLL is registered
	@$$zip = Get-ChildItem winders -Filter 'jolemak-*.zip' | Sort-Object Name | Select-Object -Last 1 #\
	if (-not $$zip) { Write-Error 'no winders/jolemak-*.zip'; exit 1 } #\
	$$dir = "winders/$$($$zip.BaseName)" #\
	if (-not (Test-Path $$dir)) { Expand-Archive $$zip.FullName -DestinationPath winders } #\
	$$msi = Get-ChildItem $$dir -Filter '*_amd64.msi' | Select-Object -First 1 #\
	if (-not $$msi) { Write-Error "no *_amd64.msi in $$dir"; exit 1 } #\
	$$dll = $$msi.Name -replace '_amd64\.msi$$', '.dll' #\
	$$find = { $(layouts) | Where-Object 'Layout File' -eq $$dll | Select-Object -First 1 } #\
	if ($$k = & $$find) { "$$dll is already installed (KLID $$($$k.PSChildName))"; exit } #\
	$$a = '/i', ('"{0}"' -f $$msi.FullName), '/qn', '/norestart' #\
	$(msiexec) #\
	"installed $$($$msi.Name) (KLID $$((& $$find).PSChildName)); sign out to use it"

# The default input method is the first tip of the first language. Older jolemak
# builds (A0xx1009) are dropped from en-CA; other languages are left alone.
use-latest: ## make the newest installed jolemak the default en-CA layout, drop older ones
	@$$k = $(layouts) | Where-Object 'Layout File' -like 'jolemak*.dll' | Sort-Object 'Layout File' | Select-Object -Last 1 #\
	if (-not $$k) { Write-Error 'no jolemak layout installed: make install'; exit 1 } #\
	$$tip = "1009:$$($$k.PSChildName.ToUpper())"; $$name = "$$tip ($$($$k.'Layout File'))" #\
	$$l = Get-WinUserLanguageList #\
	if (-not ($$l | Where-Object LanguageTag -eq 'en-CA')) { $$l.Add('en-CA') } #\
	$$ca = $$l | Where-Object LanguageTag -eq 'en-CA' #\
	$$want = @($$tip) + @($$ca.InputMethodTips | Where-Object { $$_ -notmatch '^1009:A0[0-9A-F]{2}1009$$' }) #\
	if (($$ca.InputMethodTips -join ',') -eq ($$want -join ',')) { "$$name is already the default"; exit } #\
	$$ca.InputMethodTips.Clear(); $$want | ForEach-Object { $$ca.InputMethodTips.Add($$_) } #\
	Set-WinUserLanguageList $$l -Force -WarningAction Ignore #\
	"default en-CA layout: $$name"

uninstall-2019: use-latest ## uninstall the 2019 layout (jolemak2.dll) through its MSI
	@$$p = $(products) | Where-Object DisplayName -eq '$(OLD_NAME)' #\
	if (-not $$p) { 'the 2019 layout is not installed'; exit } #\
	"uninstalling $$($$p.DisplayName) $$($$p.PSChildName)" #\
	$$a = '/x', $$p.PSChildName, '/qb' #\
	$(msiexec) #\
	'uninstalled; sign out or reboot'

##@ other

help: ## this list
	@Select-String -Path Makefile -Pattern '^##@ (.*)', '^([a-z0-9-]+):.*## (.*)' | ForEach-Object { #\
	  $$g = $$_.Matches[0].Groups #\
	  if ($$_.Line.StartsWith('##@')) { ''; $$g[1].Value } else { '  {0,-16} {1}' -f $$g[1].Value, $$g[2].Value } #\
	}

# Keeps the MSKLC build in Documents until it is packaged.
clean: ## remove the MSKLC download, build, log and unpacked winders/ folders
	@$$build = Join-Path $(DOCS) '$(BUILD_NAME)' #\
	if ((Test-Path $$build) -and -not (Test-Path 'winders/$(PACKAGE).zip')) { #\
	  "keeping $${build}: not packaged yet, make package"; $$build = $$null #\
	} #\
	$$unpacked = Get-ChildItem winders -Directory -Filter 'jolemak-*' | Where-Object { Test-Path "$$($$_.FullName).zip" } #\
	foreach ($$p in @('$(MSKLC_SETUP)', (Join-Path $(DOCS) KeyboardVerify.log), $$build) + @($$unpacked.FullName)) { #\
	  if ($$p -and (Test-Path $$p)) { Remove-Item -Recurse -Force $$p; "removed $$p" } #\
	}

status: ## show MSKLC, the installed jolemak layouts and their MSIs
	@"MSKLC 1.4 installed: $$(Test-Path '$(MSKLC_EXE)')"
	@$(layouts) | Where-Object 'Layout File' -like 'jolemak*' | Format-Table PSChildName, 'Layout File', 'Layout Text' -AutoSize
	@$(products) | Where-Object DisplayName -match 'jolemak|Colemak' | Format-Table DisplayName, DisplayVersion, PSChildName -AutoSize
