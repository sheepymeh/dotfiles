#Requires -RunAsAdministrator

Write-Host "Configuring DNS" -ForegroundColor Green
Get-NetAdapter -Physical | ForEach-Object { Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses "1.1.1.1", "1.0.0.1" }
Clear-DnsClientCache

Write-Host "Installing Group Policy" -ForegroundColor Green
Start-BitsTransfer -Source "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip" -Destination LGPO.zip
Expand-Archive lgpo.zip -DestinationPath lgpo
.\lgpo\LGPO_30\LGPO.exe /t "$PSScriptRoot\grouppolicy.txt"

Write-Host "Configuring NTP" -ForegroundColor Green
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"

Write-Host "Misc. Registry Changes" -ForegroundColor Green
if (!(Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}")) {
	New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
}
if (!(Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32")) {
	New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
}
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force

Write-Host "Uninstalling Software"
$apps = "Microsoft.549981C3F5F10", "microsoft.windowscommunicationsapps", "Microsoft.WindowsCamera", "Microsoft.XboxIdentityProvider", "MicrosoftTeams", "Microsoft.OneDriveSync", "Microsoft.WindowsAlarms", "Microsoft.ZuneMusic", "Microsoft.YourPhone", "Microsoft.XboxSpeechToTextOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.Xbox.TCUI", "Microsoft.WindowsSoundRecorder", "Microsoft.WindowsMaps", "Microsoft.WindowsFeedbackHub", "Microsoft.Todos", "Microsoft.People", "Microsoft.MicrosoftStickyNotes", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.GetHelp", "Microsoft.GamingApp", "Microsoft.BingWeather", "Microsoft.BingNews", "Microsoft.MicrosoftOfficeHub", "Microsoft.XboxGameOverlay"
foreach ($app in $apps) {
	Get-AppxPackage -allusers $app | Remove-AppxPackage
}

$wanted = "Windows-Defender-Default-Definitions", "Containers-DisposableClientVM", "VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux", "Printing-PrintToPDFServices-Features", "SearchEngine-Client-Package"
foreach ($feature in Get-WindowsOptionalFeature -Online | Where-Object state -eq Enabled) {
	if (!($wanted.Contains($feature.FeatureName))) {
		Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $feature.FeatureName
	}
}

$capabilities = "App.StepsRecorder", "App.Support.QuickAssist", "Browser.InternetExplorer", "Hello.Face.20134", "Language.Handwriting", "Language.OCR", "Language.Speech", "MathRecognizer", "Media.WindowsMediaPlayer", "Microsoft.Windows.PowerShell.ISE", "Microsoft.Windows.WordPad", "Print.Fax.Scan", "Print.Management.Console"
foreach ($capability in $capabilities) {
	Remove-WindowsCapability -Online -Name $capability
}

Write-Host "Installing Office" -ForegroundColor Green
Start-BitsTransfer -Source "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16626-20148.exe" -Destination office.exe
Start-Process office.exe -Wait -ArgumentList "/extract:office /quiet"
Write-Host "Downloading Installer"
Set-Content -Path "office/office.xml" -Value @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <Language ID="zh-cn" />
      <Language ID="de-de" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="OneNote" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="Bing" />
    </Product>
    <Product ID="ProofingTools">
      <Language ID="zh-cn" />
      <Language ID="de-de" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="PinIconsToTaskbar" Value="TRUE" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
Write-Host "Downloading Office"
Start-Process .\office\setup.exe -Wait -ArgumentList "/download office/office.xml"
Write-Host "Installing Office"
Start-Process .\office\setup.exe -Wait -ArgumentList "/configure office/office.xml"

Write-Host "Configuring Optional Features" -ForegroundColor Green
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -NoRestart -Online

Write-Host "Configuring Power Plan" -ForegroundColor Green
powercfg /change monitor-timeout-ac 4
powercfg /change monitor-timeout-dc 4
powercfg /change standby-timeout-ac 5
powercfg /change standby-timeout-dc 5
powercfg /hibernate off

Write-Host "Adding Languages" -ForegroundColor Green
$Languages = Get-WinUserLanguageList
$Languages.add("zh-Hans-CN")
$Languages.add("de-DE")
$Languages.add("ja")
Set-WinUserLanguageList $Languages

irm https://christitus.com/win | iex

Write-Host "Configuring Firefox" -ForegroundColor Green
Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe" -Wait -ArgumentList "--createprofile default-release"
$FF_PROFILE = ls "$env:APPDATA\Mozilla\Firefox\Profiles\" | Select-Object -ExpandProperty Name
Copy-Item firefox/* "$env:APPDATA\Mozilla\Firefox\Profiles\$FF_PROFILE"
Set-Content -Path "$env:APPDATA\Mozilla\Firefox\profiles.ini" -Value @"
[Install308046B0AF4A39CB]
Default=Profiles/$FF_PROFILE
Locked=1

[Profile0]
Name=default-release
IsRelative=1
Path=Profiles/$FF_PROFILE

[General]
StartWithLastProfile=1
Version=2
"@
wget https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_mauve.xpi -OutFile catppuccin_mocha_mauve.xpi
wget https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-latest.xpi -OutFile bypass_paywalls_clean-latest.xpi
& "C:\Program Files\Mozilla Firefox\firefox.exe" "$pwd\catppuccin_mocha_mauve.xpi" "$pwd\bypass_paywalls_clean-latest.xpi"

Write-Host "Configuring VS Code" -ForegroundColor Green
Copy-Item code\* "$env:appdata\Code\User"
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --install-extension Catppuccin.catppuccin-vsc
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --install-extension Catppuccin.catppuccin-vsc-icons
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --install-extension ms-python.python
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --install-extension Vue.volar
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" --install-extension svelte.svelte-vscode

Write-Host "Please reboot your system to finish" -ForegroundColor Green
