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
$GitUserName = "Theodore L'Heureux"

#Email used by git.
$GitEmail = "theodorelheureux@gmail.com"

$GitSignKeyId = "881B04F1BF8134372145954483654F9843F106ED"

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

#endregionn