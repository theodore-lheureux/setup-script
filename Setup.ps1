Import-Module $PSScriptRoot\Scripts\Params.ps1
Import-Module $PSScriptRoot\Scripts\Mouse-Speed.ps1
Import-Module $PSScriptRoot\Scripts\RegKeys.ps1
Import-Module $PSScriptRoot\Scripts\TaskHandler.ps1

if ($ChangeKeyboardLayoutToUs -eq "1") {
	Set-WinUserLanguageList -LanguageList en-US -Force
	Write-Host '[Done] Set keyboard layout to en-US.'
}

#region Registry parameters 
Set-ItemProperty -Path $AppsUseLightThemeKey -Name AppsUseLightTheme -Value $AppsUseLightTheme
Write-Host '[Done] Set AppsUseLightThem to ' -NoNewline
Write-Host $AppsUseLightTheme


if ($AskForMouseSpeed -eq "1") {
	$MouseSpeed = Read-Host -Prompt 'Mouse speed ? (0-20)'
}
Set-Mouse -Speed $MouseSpeed;
Write-Host '[Done] Set mouse speed to '  -NoNewline
Write-Host $MouseSpeed

Set-ItemProperty -Path $TaskbarSmallIconsKey -Name TaskbarSmallIcons -Value $TaskbarSmallIcons
Write-Host '[Done] Set TaskbarSmallIcons to ' -NoNewline
Write-Host $TaskbarSmallIcons

Set-ItemProperty -Path $MMTaskbarEnabledKey -Name MMTaskbarEnabled -Value $MMTaskbarEnabled
Write-Host '[Done] Make taskbar appear only on one monitor'

Set-ItemProperty -Path $SystemUsesLightThemeKey -Name SystemUsesLightTheme -Value $SystemUsesLightTheme
Write-Host '[Done] Set SystemUsesLightTheme to ' -NoNewline
Write-Host $SystemUsesLightTheme

Set-ItemProperty -Path $HideIconsKey -Name "HideIcons" -Value $HideIcons
Write-Host '[Done] Make desktop icons hidden or visible'

Get-Process "explorer" | Stop-Process
Write-Host '[Done] Restart windows explorer'
#endregion

#region Main monitor
$Screen = Read-Host -Prompt 'Is monitor ok ? (1/0)'

if ($Screen -eq "0") {
	.$PSScriptRoot\ExtraSoftware\multimonitortool-x64\MultiMonitorTool.exe /SetNextPrimary
	Write-Host '[Done] Change main monitor'
}
#endregion

#region Start Rust Job
if ($AlwaysSkipRustInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallRust -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install Rust ? (1/0)'
	}

	if ($Screen -eq "1") {
		$cppInstallScript = {
				.$PSScriptRoot\ExtraSoftware\vs_Enterprise.exe modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Enterprise" --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --quiet --norestart
		}
		$cppInstallEndScript = {
			.$PSScriptRoot\ExtraSoftware\rustup-init.exe -y -q
			Write-Host '[Done] Rust Install'
		}

		Start-Task -Name "cpp" -Script $cppInstallScript -EndScript $cppInstallEndScript -ComplexName "Install VS cpp tools"
	}
	else {
		Write-Host '[Skipped] Install Rust'
	}
}
else {
	Write-Host '[Skipped] Install Rust'
}
#endregion

#region VS Code remove extension
if ($AlwaysSkipVSCodeExtensionUninstall -eq "0") {

	$Screen = "0"

	if ($AlwaysUninstallVSCodeExtension -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Uninstall useless VSCode extensions ? (1/0)'
	}

	if ($Screen -eq "1") {
		$removeVSScript = {
			Remove-Item "C:\Program Files\Microsoft VS Code\data\extensions\*" -Recurse -Force -ErrorAction SilentlyContinue
		}
		$removeVSEndScript = {
			Write-Host '[Done] Uninstall useless VSCode extensions'
		}
		Start-Task -Name "removeVS" -Script $removeVSScript -EndScript $removeVSEndScript -ComplexName "Uninstall useless VSCode extensions"
	}
	else {
		Write-Host '[Skipped] Uninstall useless VSCode extensions'
	}
}
else {
	Write-Host '[Skipped] Uninstall useless VSCode extensions'
}
#endregion

#region Start Cmder Job
if ($AlwaysSkipCmderInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallCmder -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install Cmder ? (1/0)'
	}

	if ($Screen -eq "1") {
		$cmderInstallScript = {
			Copy-Item -Path "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\cmder.zip" -Destination "C:\Users\2032422\Documents\" 
			Start-Process "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x C:\Users\2032422\Documents\cmder.zip -oC:\" -Wait
		}
		$cmderInstallEndScript = {
			mkdir 'C:\Users\2032422\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe' > $null
			mkdir 'C:\Users\2032422\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState' > $null
			Copy-Item -Path "$PSScriptRoot\ExtraSoftware\settings.json" -Destination "C:\Users\2032422\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
			Write-Host '[Done] Cmder Install'
		}

		Start-Task -Name "cmderInstall" -Script $cmderInstallScript -EndScript $cmderInstallEndScript -ComplexName "Cmder Install"
	}	
	else {
		Write-Host '[Skipped] Install Cmder'
	}
}
else {
	Write-Host '[Skipped] Install Cmder'
}
#endregion

#region Start CMake Job
if ($AlwaysSkipCMakeInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallCMake -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install CMake ? (1/0)'
	}

	if ($Screen -eq "1") {
		$cmakeInstallScript = {
			Start-Process msiexec.exe -Wait -ArgumentList "/i \\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\cmake-3.26.0-windows-x86_64.msi /qn"

			$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
			$oldpath += ";C:\Program Files\CMake\bin"
			Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $oldpath
		}
		$cmakeInstallEndScript = {
			Write-Host '[Done] CMake Install'
		}

		Start-Task -Name "cmakeinstall" -Script $cmakeInstallScript -EndScript $cmakeInstallEndScript -ComplexName "CMake Install"
	}	
	else {
		Write-Host '[Skipped] Install CMake'
	}
}
else {
	Write-Host '[Skipped] Install CMake'
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

$powertoysInstallScript = {
	winget install Microsoft.PowerToys -s winget
}
$powertoysEndScript = {
	Write-Host '[Done] Powertoys Install'
}

Start-Task -Name "powertoys" -Script $powertoysInstallScript -EndScript $powertoysEndScript -ComplexName "Install Powertoys"


$gitsetupScript = {
	Start-Process msiexec.exe -Wait -ArgumentList '/i "\\laboratoire.collegeem.qc.ca\Stockage\usagers\Etudiants\2032422\ExtraSoftware\GnuPG.msi" /q'
	
	$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
	$oldpath += ";C:\Program Files (x86)\gnupg\bin"
	Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $oldpath
}

$gitsetupEndScript = {
	."C:\Program Files (x86)\gnupg\bin\gpg.exe" --import $PSScriptRoot\ExtraSoftware\keypublic.txt
	Write-Host "[Done] Imported Git public key into gpg"
	."C:\Program Files (x86)\gnupg\bin\gpg.exe" --import $PSScriptRoot\ExtraSoftware\key.txt
	Write-Host "[Done] Imported Git private key into gpg"

	git config --global user.signingkey $GitSignKeyId
	git config --global commit.gpgsign true
	git config --global gpg.program "c:/Program Files (x86)/GnuPG/bin/gpg.exe"
	Write-Host '[Done] Setup git private key'
}

Start-Task -Name "gitInstall" -Script $gitsetupScript -EndScript $gitsetupEndScript -ComplexName "Git Setup"
#endregion

#region Change default browser
.$PSScriptRoot\ExtraSoftware\SetDefaultBrowser\SetDefaultBrowser.exe Edge delay=1000
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
		msiexec /x "$PSScriptRoot\ExtraSoftware\2b30d.msi"
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

#region Wait for jobs to finish
Await-Tasks
Write-Host '[Done] All tasks completed.'

Start-Sleep -s 1
#endregion



