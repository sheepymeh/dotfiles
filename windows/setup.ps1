#Requires -RunAsAdministrator

New-Item -ItemType directory -Path "~\Downloads" -Name "setup"
Set-Location -Path ~\Downloads\setup

Write-Host "Installing Group Policy" -ForegroundColor Green
Start-BitsTransfer -Source "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip" -Destination LGPO.zip
Expand-Archive lgpo.zip -DestinationPath lgpo
.\lgpo\LGPO_30\LGPO.exe /t "$PSScriptRoot\grouppolicy.txt"

Write-Host "Ensure that a DoH DNS server has been set up, then continue" -ForegroundColor Yellow
Pause

Write-Host "Enabling Dark Mode" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type DWORD -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type DWORD -Force

Write-Host "Configuring Power Plan" -ForegroundColor Green
powercfg /change monitor-timeout-ac 3
powercfg /change monitor-timeout-dc 3
powercfg /change standby-timeout-ac 10
powercfg /change standby-timeout-dc 10

Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Type DWORD -Value 1
if (!(Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}")) {
	New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
}
if (!(Test-Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32")) {
	New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
}
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force

Write-Host "Enabling Storage Sense" -ForegroundColor Green
$storage_sense_key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense"
if (!(Test-Path "$storage_sense_key")) {
    New-Item -Path "$storage_sense_key"
}
if (!(Test-Path "$storage_sense_key\Parameters")) {
    New-Item -Path "$storage_sense_key\Parameters"
}
if (!(Test-Path "$storage_sense_key\Parameters\StoragePolicy")) {
    New-Item -Path "$storage_sense_key\Parameters\StoragePolicy"
}
Set-ItemProperty -Path "$storage_sense_key\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
Set-ItemProperty -Path "$storage_sense_key\Parameters\StoragePolicy" -Name "2048" -Type DWord -Value 7
Set-ItemProperty -Path "$storage_sense_key\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 1
Set-ItemProperty -Path "$storage_sense_key\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 1
Set-ItemProperty -Path "$storage_sense_key\Parameters\StoragePolicy" -Name "256" -Type DWord -Value 14

Write-Host "Setting Time" -ForegroundColor Green
Set-TimeZone -Name "Malay Peninsula Standard Time"

Write-Host "Enabling BitLocker" -ForegroundColor Green
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes128 -UsedSpaceOnly -SkipHardwareTest -TPMProtector

Write-Host "Installing Chocolatey" -ForegroundColor Green

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
choco feature enable -n=useRememberedArgumentsForUpgrades

Write-Host "Installing Software" -ForegroundColor Green

choco install nextcloud-client -y
choco install 7zip -y
choco install Firefox --params "/NoDesktopShortcut /NoAutoUpdate /RemoveDistributionDir" -y
choco install transmission -y
choco install spotify -y
choco install signal --params "/NoTray /NoShortcut" -y
choco install nodejs-lts -y
choco install php -y
choco install adb -y
choco install vscodium --params "/NoDesktopIcon /AssociateWithFiles" -y
choco install git --params "/GitOnlyOnPath /NoAutoCrlf /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration /WindowsTerminal /Editor:VSCodium" -y
choco install powertoys -y

if ((Get-WmiObject win32_VideoController).description.Contains("NVIDIA")) {
	choco install nvidia-display-driver --package-parameters="'/dch'" -y
}

Write-Host "Installing WSL & Sandbox"
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -NoRestart -Online
wsl --install

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

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global pull.rebase false

codium
Stop-Process -Name VSCodium
Copy-Item "$PSScriptRoot\..\code\settings.json" "$env:APPDATA\VSCodium\User"
Copy-Item "$PSScriptRoot\..\code\keybindings.json" "$env:APPDATA\VSCodium\User"
Set-Content -Path "$env:APPDATA\VSCodium\product.json" -Value @"
{
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  },
  "nameLong": "Visual Studio Code"
}
"@

Write-Host "Adding Languages" -ForegroundColor Green
$Languages = Get-WinUserLanguageList
$Languages.add("zh-Hans-CN")
$Languages.add("de-DE")
$Languages.add("ja")
Set-WinUserLanguageList -LanguageList $Languages -Force

Write-Host "Installing Office" -ForegroundColor Green
Start-BitsTransfer -Source "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12624-20320.exe" -Destination office.exe
Start-Process office.exe -Wait -ArgumentList "/extract:office /quiet"
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
