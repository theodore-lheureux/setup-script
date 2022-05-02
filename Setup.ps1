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
$AlwaysSkipNetSupportUninstall = "0"
$AlwaysSkipVNCViewerInstall = "0"
$AlwaysSkipCmderInstall = "0"
$AlwaysSkipVSCodeExtensionUninstall = "0"

$AlwaysUninstallNetSupport = "0"
$AlwaysInstallVNCViewer = "0"
$AlwaysInstallCmder = "1"
$AlwaysUninstallVSCodeExtension = "0"

$AskForMouseSpeed = "1"
$ChangeKeyboardLayoutToUs = "1"

#endregion

if ($ChangeKeyboardLayoutToUs -eq "1") {
	Set-WinUserLanguageList -LanguageList en-US -Force
	Write-Host '[Done] Set keyboard layout to en-US.'
}

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

$Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $Path -Name "HideIcons" -Value $HideIcons
Write-Host '[Done] Make desktop icons hidden or visible'

Get-Process "explorer"| Stop-Process
Write-Host '[Done] Restart windows explorer'
#endregion

#region Main monitor
$Screen = Read-Host -Prompt 'Is monitor ok ? (1/0)'

if ($Screen -eq "0") {
	Z:\ExtraSoftware\multimonitortool-x64\MultiMonitorTool.exe /SetNextPrimary
	Write-Host '[Done] Change main monitor'
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
		msiexec /x "Z:\ExtraSoftware\2b30d.msi"
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
		msiexec /i "Z:\ExtraSoftware\VNC-Viewer\VNC-Viewer-6.21.1109-Windows-en-64bit.msi"
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

add-appxpackage "Z:\ExtraSoftware\Microsoft.WindowsTerminal_1.10.2383.0_8wekyb3d8bbwe.msixbundle"

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
		code --uninstall-extension formulahendry.dotnet-test-explorer
		code --uninstall-extension formulahendry.dotnet
		code --uninstall-extension ms-dotnettools.vscode-dotnet-runtime
		code --uninstall-extension mikael.angular-beastcode
		code --uninstall-extension johnpapa.angular-essentials
		code --uninstall-extension angular.ng-template
		code --uninstall-extension johnpapa.angular2
		code --uninstall-extension bencoleman.armview
		code --uninstall-extension rahulsahay.csharp-aspnetcore
		code --uninstall-extension temilaj.asp-net-core-vs-code-extension-pack
		code --uninstall-extension schneiderpat.aspnet-helper
		code --uninstall-extension ms-vscode.azure-account
		code --uninstall-extension msazurermtools.azurerm-vscode-tools
		code --uninstall-extension ms-vscode.vscode-node-azure-pack
		code --uninstall-extension ms-dotnettools.csharp
		code --uninstall-extension thekalinga.bootstrap4-vscode
		code --uninstall-extension artlaman.chalice-color-theme
		code --uninstall-extension artlaman.chalice-icon-theme
		code --uninstall-extension msjsdiag.debugger-for-chrome
		code --uninstall-extension firefox-devtools.vscode-firefox-debug
		code --uninstall-extension msjsdiag.debugger-for-edge
		code --uninstall-extension hediet.vscode-drawio
		code --uninstall-extension editorconfig.editorconfig
		code --uninstall-extension ms-ceintl.vscode-language-pack-fr
		code --uninstall-extension eamodio.gitlens
		code --uninstall-extension ms-vscode.hexeditor
		code --uninstall-extension ecmel.vscode-html-css
		code --uninstall-extension heaths.vscode-guid
		code --uninstall-extension ritwickdey.liveserver
		code --uninstall-extension pkief.material-icon-theme
		code --uninstall-extension eg2.vscode-npm-script
		code --uninstall-extension jmrog.vscode-nuget-package-manager
		code --uninstall-extension nrwl.angular-console
		code --uninstall-extension johnpapa.vscode-peacock
		code --uninstall-extension jebbs.plantuml
		code --uninstall-extension esbenp.prettier-vscode
		code --uninstall-extension ms-python.python
		code --uninstall-extension ms-vscode-remote.remote-containers
		code --uninstall-extension ms-vscode-remote.remote-ssh
		code --uninstall-extension ms-vscode-remote.vscode-remote-extensionpack
		code --uninstall-extension ms-vscode-remote.remote-wsl
		code --uninstall-extension jock.svg
		code --uninstall-extension hbenl.vscode-test-explorer
		code --uninstall-extension darfka.vbscript
		code --uninstall-extension johnpapa.winteriscoming

		code --install-extension dsznajder.es7-react-js-snippets
		code --install-extension vscode-icons-team.vscode-icons
		code --install-extension redhat.java
		code --install-extension react.vscode-xml
		code --install-extension ritwickdey.liveserver
		Write-Host '[Done] Uninstall useless VSCode extensions'
	}
	else {
		Write-Host '[Skipped] Uninstall useless VSCode extensions'
	}
}
else {
	Write-Host '[Skipped] Uninstall useless VSCode extensions'
}
#endregion

#region Install Cmder
if ($AlwaysSkipCmderInstall -eq "0") {

	$Screen = "0"

	if ($AlwaysInstallCmder -eq "1") {
		$Screen = "1"
	}
	else {
		$Screen = Read-Host -Prompt 'Install Cmder ? (1/0)'
	}

	if ($Screen -eq "1") {
		Copy-Item -Recurse "Z:\ExtraSoftware\cmder" "C:\cmder"
		Write-Host '[Done] Install Cmder'
	}	
	else {
		Write-Host '[Skipped] Install Cmder'
	}
}
else {
	Write-Host '[Skipped] Install Cmder'
}
#endregion