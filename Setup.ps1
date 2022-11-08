#region Param

#Apps use light theme by default; 1 for light theme in apps, and 0 for dark theme.
$AppsUseLightTheme = 0

#System uses dark theme by default; 1 for light theme in apps, and 0 for dark theme.
$SystemUsesLightTheme = 0

#Taskbar is big by default; 1 for smaller taskbar, 0 to keep it big.
$TaskbarSmallIcons = 1

#Taskbar is on all monitors by default; 1 to keep it that way, 0 to make it appear only on main monitor.
$MMTaskbarEnabled = 0

#Change to 1 to hide icons on desktop, 0 to show them.
$HideIcons = 1

#Mouse speed must be between 1 and 20 (inclusive), default is 10.
$MouseSpeed = 3

#Username used by git.
$GitUserName = "Théodore L'Heureux"

#Email used by git.
$GitEmail = "theodorelheureux@gmail.com"

#Skip some questions when executing script ? 0 if false, 1 if true.
$AlwaysSkipNetSupportUninstall = "1"
$AlwaysSkipVNCViewerInstall = "1"
$AlwaysSkipCmderInstall = "0"
$AlwaysSkipRustInstall = "0"
$AlwaysSkipVSCodeExtensionUninstall = "0"

$AlwaysUninstallNetSupport = "0"
$AlwaysInstallVNCViewer = "0"
$AlwaysInstallCmder = "1"
$AlwaysInstallRust = "1"
$AlwaysUninstallVSCodeExtension = "0"

$AskForMouseSpeed = "0"
$ChangeKeyboardLayoutToUs = "1"

#endregion

#region Mouse sensitivity
function Set-Mouse() {

	[cmdletbinding()]
	Param(
		[ValidateRange(1, 20)] 
		[int]
		$Speed,
		[ValidateRange(-1, 100)] 
		[int]
		$ScrollLines
	)       

	$MethodDefinition = @"
		[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
		public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
"@
	$User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Set" -Namespace Win32Functions -PassThru
	if ($Speed) {
		Write-Verbose "new mouse speed: $Speed"
		$User32::SystemParametersInfo(0x0071, 0, $Speed, 0) | Out-Null
		Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -Value $Speed
	}
	if ($ScrollLines) {
		Write-Verbose "new mouse scrollLines: $ScrollLines"
		$User32::SystemParametersInfo(0x0069, $ScrollLines, 0, 0x01) | Out-Null
		Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name WheelScrollLines -Value $ScrollLines
	}
}
#endregion

if ($ChangeKeyboardLayoutToUs -eq "1") {
	Set-WinUserLanguageList -LanguageList en-US -Force
	Write-Host '[Done] Set keyboard layout to en-US.'
}

#region Registry parameters 
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $AppsUseLightTheme
Write-Host '[Done] Set AppsUseLightThem to ' -NoNewline
Write-Host $AppsUseLightTheme


if ($AskForMouseSpeed -eq "1") {
	$MouseSpeed = Read-Host -Prompt 'Mouse speed ? (0-20)'
}
Set-Mouse -Speed $MouseSpeed;
Write-Host '[Done] Set mouse speed to '  -NoNewline
Write-Host $MouseSpeed

Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarSmallIcons -Value $TaskbarSmallIcons
Write-Host '[Done] Set TaskbarSmallIcons to ' -NoNewline
Write-Host $TaskbarSmallIcons

Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarEnabled -Value $MMTaskbarEnabled
Write-Host '[Done] Make taskbar appear only on one monitor'

Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SystemUsesLightTheme -Value $SystemUsesLightTheme
Write-Host '[Done] Set SystemUsesLightTheme to ' -NoNewline
Write-Host $SystemUsesLightTheme

$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $Path -Name "HideIcons" -Value $HideIcons
Write-Host '[Done] Make desktop icons hidden or visible'

Get-Process "explorer" | Stop-Process
Write-Host '[Done] Restart windows explorer'
#endregion

#region Main monitor
$Screen = Read-Host -Prompt 'Is monitor ok ? (1/0)'

if ($Screen -eq "0") {
	\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\multimonitortool-x64\MultiMonitorTool.exe /SetNextPrimary
	Write-Host '[Done] Change main monitor'
}
#endregion

#region Start Rust Job
$RustDone = $false;

if ($AlwaysSkipRustInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallRust -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install Rust ? (1/0)'
	}

	if ($Screen -eq "1") {
		Start-Job -Name rustinstall -Scriptblock {
			\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\vs_Enterprise.exe modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Enterprise" --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --quiet --norestart
			\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\rustup-init.exe -y -q
		}
	}
	else {
		Write-Host '[Skipped] Install Rust'
		$RustDone = $true;
	}
}
else {
	Write-Host '[Skipped] Install Rust'
	$RustDone = $true;
}
#endregion

#region VS Code remove extension
$VScodeDone = $false;

if ($AlwaysSkipVSCodeExtensionUninstall -eq "0") {

	$Screen = "0"

	if ($AlwaysUninstallVSCodeExtension -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Uninstall useless VSCode extensions ? (1/0)'
	}

	if ($Screen -eq "1") {
		Start-Job -Name removeVS -Scriptblock { 
			Remove-Item "C:\Program Files\Microsoft VS Code\data\extensions\*" -Recurse -Force -ErrorAction SilentlyContinue
			Copy-Item -Path "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\extensions.zip" -Destination "C:\Program Files\Microsoft VS Code\data"
			Start-Process "C:\Program Files\7-Zip\7zG.exe" -ArgumentList "x C:\Program Files\Microsoft VS Code\data\extensions.zip -oC:\Program Files\Microsoft VS Code\data\" -Wait 
		}

		Write-Host '[Done] Uninstall useless VSCode extensions'
	}
	else {
		Write-Host '[Skipped] Uninstall useless VSCode extensions'
		$VScodeDone = $true;
	}
}
else {
	Write-Host '[Skipped] Uninstall useless VSCode extensions'
	$VScodeDone = $true;
}
#endregion

#region Start Cmder Job
$cmderDone = $false;

if ($AlwaysSkipCmderInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallCmder -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install Cmder ? (1/0)'
	}

	if ($Screen -eq "1") {
		Start-Job -Name cmder -Scriptblock {
			Copy-Item -Path "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\cmder.zip" -Destination "C:\Users\2032422\Documents" 
			Start-Process "C:\Program Files\7-Zip\7zG.exe" -ArgumentList "x C:\Users\2032422\Documents\cmder.zip -oC:\" -Wait
		}
	}	
	else {
		Write-Host '[Skipped] Install Cmder'
		$cmderDone = $true;
	}
}
else {
	Write-Host '[Skipped] Install Cmder'
	$cmderDone = $true;
}
#endregion

#region Git configuration
git config --global user.name $GitUserName
Write-Host '[Done] Set git user name to "' -NoNewline
Write-Host $GitUserName -NoNewline
Write-Host '"'
git config --global user.email $GitEmail
Write-Host '[Done] Set git email to "' -NoNewline
Write-Host $GitEmail -NoNewline
Write-Host '"'

$gitDone = $false;

Start-Job -Name gitsetup -Scriptblock {
	Start-Process msiexec.exe -Wait -ArgumentList '/i "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\GnuPG.msi" /q'
	
			$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
			$oldpath += ";C:\Program Files (x86)\gnupg\bin"
			Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $oldpath
}
#endregion

#region Change default browser
\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\SetDefaultBrowser\SetDefaultBrowser.exe Edge delay=1000
Write-Host '[Done] Change default browser to Edge'
#endregion

#region Uninstall NetSupport School
if ($AlwaysSkipNetSupportUninstall -eq "0") {

	$Screen = "0"

	if ($AlwaysUninstallNetSupport -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Uninstall NetSupport School ? (1/0)'
	}

	if ($Screen -eq "1") {
		msiexec /x "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\2b30d.msi"
		Write-Host '[Done] Uninstall NetSupport School'
	}
	else {
		Write-Host '[Skipped] Uninstall NetSupport School'
	}
}
else {
	Write-Host '[Skipped] Uninstall NetSupport School'
}
#endregion

#region Install VNCViewer
if ($AlwaysSkipVNCViewerInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallVNCViewer -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install VNC-Viewer ? (1/0)'
	}

	if ($Screen -eq "1") {
		msiexec /i "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\VNC-Viewer\VNC-Viewer-6.21.1109-Windows-en-64bit.msi"
		Write-Host '[Done] Install VNC-Viewer'
	}	
	else {
		Write-Host '[Skipped] Install VNC-Viewer'
	}
}
else {
	Write-Host '[Skipped] Install VNC-Viewer'
}
#endregion

#region Wait for jobs to finish
$jobsNotDone = $true;

while ($jobsNotDone -eq $true) {

	if ($cmderDone -eq $false) {

		$cmderStatus = (Get-Job -Name cmder) | Out-String

		if ($cmderStatus.contains("Completed")) {
			Copy-Item -Path "Z:\ExtraSoftware\settings.json" -Destination "C:\Users\2032422\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
			Write-Host '[Done] Cmder Install'
			$cmderDone = $true
		}
		elseif ($cmderStatus.contains("Running")) {
			$text = '[Running] Cmder Install'
			for ($i = 0; $i -lt $text.Length; $i++) {
				$c = $text[$i]
		
				Write-Host $c -NoNewline
				Start-Sleep -Milliseconds 1
			}
			Write-Host ""
		}
		elseif ($cmderStatus.contains("Blocked")) {
			Write-Host '[Error] Cmder Install Blocked !!!'
			$cmderDone = $true
		}
		elseif ($cmderStatus.contains("Failed")) {
			Write-Host '[Error] Cmder Install Failed !!!'
			$cmderDone = $true
		}
	}

	if ($RustDone -eq $false) {
		
		$RustStatus = (Get-Job -Name rustinstall) | Out-String
	
		if ($RustStatus.contains("Completed")) {
			Write-Host '[Done] Rust Install'
			$RustDone = $true
		}
		elseif ($RustStatus.contains("Running")) {
			$text = '[Running] Rust Install'
			for ($i = 0; $i -lt $text.Length; $i++) {
				$c = $text[$i]
		
				Write-Host $c -NoNewline
				Start-Sleep -Milliseconds 1
			}
			Write-Host ""
		}
		elseif ($RustStatus.contains("Blocked")) {
			Write-Host '[Error] Rust Install Blocked !!!'
			$RustDone = $true
		}
		elseif ($RustStatus.contains("Failed")) {
			Write-Host '[Error] Rust Install Failed !!!'
			$RustDone = $true
		}
	}

	if ($VScodeDone -eq $false) {

		$VScodeStatus = (Get-Job -Name removeVS) | Out-String

		if ($VScodeStatus.contains("Completed")) {
			Write-Host '[Done] Remove useless VScode extensions'
			$VScodeDone = $true
		}
		elseif ($VScodeStatus.contains("Running")) {
			$text = '[Running] Remove useless VScode extensions'
			for ($i = 0; $i -lt $text.Length; $i++) {
				$c = $text[$i]
		
				Write-Host $c -NoNewline
				Start-Sleep -Milliseconds 1
			}
			Write-Host ""
		}
		elseif ($VScodeStatus.contains("Blocked")) {
			Write-Host '[Error] Remove useless VScode extensions !!!'
			$VScodeDone = $true
		}
		elseif ($VScodeStatus.contains("Failed")) {
			Write-Host '[Error] Remove useless VScode extensions !!!'
			$VScodeDone = $true
		}
	}

	if ($gitDone -eq $false) {

		$gitStatus = (Get-Job -Name gitsetup) | Out-String

		if ($gitStatus.contains("Completed")) {
			."C:\Program Files (x86)\gnupg\bin\gpg.exe" --import \\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\keypublic.txt
			Write-Host "[Done] Imported Git public key into gpg"
			."C:\Program Files (x86)\gnupg\bin\gpg.exe" --import \\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\key.txt
			Write-Host "[Done] Imported Git private key into gpg"

			git config --global user.signingkey 881B04F1BF8134372145954483654F9843F106ED
			git config --global commit.gpgsign true
			git config --global gpg.program "c:/Program Files (x86)/GnuPG/bin/gpg.exe"
			Write-Host '[Done] Setup git private key'
			$gitDone = $true
		}
		elseif ($gitStatus.contains("Running")) {
			$text = '[Running] Setup git private key'
			for ($i = 0; $i -lt $text.Length; $i++) {
				$c = $text[$i]
		
				Write-Host $c -NoNewline
				Start-Sleep -Milliseconds 1
			}
			Write-Host ""
		}
		elseif ($gitStatus.contains("Blocked")) {
			Write-Host '[Error] Setup git private key !!!'
			$gitDone = $true
		}
		elseif ($gitStatus.contains("Failed")) {
			Write-Host '[Error] Setup git private key !!!'
			$gitDone = $true
		}
	}

	if ($VScodeDone -eq $true -and $cmderDone -eq $true -and $RustDone -eq $true -and $gitDone -eq $true) {
		Write-Host '[Done] All tasks completed.'
		$jobsNotDone = $false
	}

	Start-Sleep -s 1
}
#endregion



