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