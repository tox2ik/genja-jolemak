# Build and install the jolemak Windows layout. Recipes run in pwsh (native Windows GNU make).
# Start with:  make help

SHELL       := pwsh.exe
.SHELLFLAGS := -NoProfile -NoLogo -Command

# MSKLC 1.4 is not on winget; this is Microsoft's own download.
MSKLC_URL := https://download.microsoft.com/download/6/f/5/6f5ce43a-e892-4fd1-b9a6-1a0cbb64e6e2/MSKLC.exe
MSKLC_EXE := C:/Program Files (x86)/Microsoft Keyboard Layout Creator 1.4/MSKLC.exe
# The downloaded installer (gitignored).
MSKLC_SETUP := opt/msklc/MSKLC.exe

# The installed 2019 layout: its MSI's DisplayName (= the KBD description in the klc).
OLD_NAME := Colemak version by Jaroslav
UNINSTALL_KEYS := 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

.DEFAULT_GOAL := help

##@ build

msklc-download: ## download the MSKLC 1.4 installer to opt/msklc/ and check its signature
	@if (-not (Test-Path '$(MSKLC_SETUP)')) { New-Item -ItemType Directory -Force opt/msklc | Out-Null; Invoke-WebRequest '$(MSKLC_URL)' -OutFile '$(MSKLC_SETUP)' -UseBasicParsing }; $$s = Get-AuthenticodeSignature '$(MSKLC_SETUP)'; if ($$s.Status -ne 'Valid' -or $$s.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') { Write-Error "bad signature: $$($$s.Status) $$($$s.SignerCertificate.Subject)"; exit 1 }; Get-Item '$(MSKLC_SETUP)' | Format-Table Name, Length, LastWriteTime

msklc: msklc-download ## install Microsoft Keyboard Layout Creator 1.4 (not on winget)
	@if (Test-Path '$(MSKLC_EXE)') { Write-Output 'MSKLC 1.4 is already installed'; exit 0 }; $$msi = Get-ChildItem opt/msklc -Recurse -Filter MSKLC.msi | Select-Object -First 1; if (-not $$msi) { Write-Output 'MSKLC.exe only unpacks: pick opt\msklc as the folder'; Start-Process '$(MSKLC_SETUP)' -Wait; $$msi = Get-ChildItem opt/msklc -Recurse -Filter MSKLC.msi | Select-Object -First 1 }; if (-not $$msi) { Write-Error 'MSKLC.msi not found under opt/msklc'; exit 1 }; $$r = Start-Process msiexec.exe -Verb RunAs -Wait -PassThru -ArgumentList '/i', ('"{0}"' -f $$msi.FullName), '/qb'; if ($$r.ExitCode -notin 0, 3010) { Write-Error "msiexec failed: $$($$r.ExitCode)"; exit 1 }; Write-Output "installed: $$(Test-Path '$(MSKLC_EXE)')"

##@ install

uninstall-2019: ## uninstall the 2019 layout (jolemak2.dll) through its MSI, asks first
	@$$p = Get-ItemProperty $(UNINSTALL_KEYS) -ErrorAction SilentlyContinue | Where-Object DisplayName -eq '$(OLD_NAME)'; if (-not $$p) { Write-Output 'the 2019 layout is not installed'; exit 0 }; if ((Read-Host "Uninstall '$$($$p.DisplayName)' $$($$p.PSChildName)? Type yes") -ne 'yes') { Write-Output 'aborted'; exit 1 }; $$r = Start-Process msiexec.exe -Verb RunAs -Wait -PassThru -ArgumentList '/x', $$p.PSChildName, '/qb'; if ($$r.ExitCode -notin 0, 3010) { Write-Error "msiexec failed: $$($$r.ExitCode)"; exit 1 }; Write-Output 'uninstalled; sign out or reboot before installing the new build'

##@ other

help: ## this list
	@Select-String -Path Makefile -Pattern '^##@ (.*)', '^([a-z0-9-]+):.*## (.*)' | ForEach-Object { $$g = $$_.Matches[0].Groups; if ($$_.Line.StartsWith('##@')) { ''; $$g[1].Value } else { '  {0,-16} {1}' -f $$g[1].Value, $$g[2].Value } }

status: ## show MSKLC, the installed jolemak layouts and their MSIs
	@Write-Output "MSKLC 1.4 installed: $$(Test-Path '$(MSKLC_EXE)')"
	@Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts' | Get-ItemProperty | Where-Object 'Layout File' -like 'jolemak*' | Format-Table PSChildName, 'Layout File', 'Layout Text' -AutoSize
	@Get-ItemProperty $(UNINSTALL_KEYS) -ErrorAction SilentlyContinue | Where-Object DisplayName -match 'jolemak|Colemak' | Format-Table DisplayName, DisplayVersion, PSChildName -AutoSize
