#Requires -RunAsAdministrator

New-Item -ItemType directory -Path "~\Downloads" -Name "setup"
Set-Location -Path ~\Downloads\setup

Write-Host "Downloading Installers" -ForegroundColor Green

$downloads = @()
$zips = @()

# NVIDIA
if ((Get-WmiObject win32_VideoController).description == "NVIDIA GeForce GTX 1070") {
	# Drivers
	$downloads += Start-BitsTransfer -Source "https://us.download.nvidia.com/Windows/461.40/461.40-desktop-win10-64bit-international-dch-whql.exe" -Destination nvidia.exe -DisplayName "NVIDIA Drivers" -Asynchronous
	# CUDA
	$downloads += Start-BitsTransfer -Source "http://developer.download.nvidia.com/compute/cuda/11.0.3/network_installers/cuda_11.0.3_win10_network.exe" -Destination cuda.exe -DisplayName "CUDA" -Asynchronous
	# RTX Voice
	$downloads += Start-BitsTransfer -Source "https://developer.nvidia.com/rtx/broadcast_engine/secure/NVIDIA_RTX_Voice.exe" -Destination rtx-voice.exe -DisplayName "RTX Voice" -Asynchronous
	# MSI Afterburner
	$downloads += Start-BitsTransfer -Source "https://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip?__token__=$(Invoke-RestMethod https://www.msi.com/api/v1/get_token?date=$(Get-Date -format 'yyyyMMdd'))" -Destination afterburner.zip -DisplayName "Afterburner" -Asynchronous
}

# Nextcloud
$downloads += Start-BitsTransfer -Source "https://download.nextcloud.com/desktop/releases/Windows/latest" -Destination nextcloud.exe -DisplayName "Nextcloud" -Asynchronous
# HxD
$downloads += Start-BitsTransfer -Source "https://mh-nexus.de/downloads/HxDSetup.zip" -Destination hxd.zip -DisplayName "HxD" -Asynchronous
# 7-Zip
$downloads += Start-BitsTransfer -Source "https://www.7-zip.org/a/7z1900-x64.msi" -Destination 7z.msi -DisplayName "7-Zip" -Asynchronous
# Firefox
$downloads += Start-BitsTransfer -Source "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" -Destination firefox.msi -DisplayName "Firefox" -Asynchronous
# Transmission
$version = (Invoke-WebRequest "https://api.github.com/repos/transmission/transmission/releases/latest" -UseBasicParsing | ConvertFrom-Json).tag_name
$downloads += Start-BitsTransfer -Source "https://github.com/transmission/transmission-releases/raw/master/transmission-$version-x64.msi" -Destination transmission.msi -DisplayName "Transmission" -Asynchronous
# Wireshark
$downloads += Start-BitsTransfer -Source "https://www.wireshark.org/download/win64/Wireshark-win64-latest.msi" -Destination wireshark.msi -DisplayName "Wireshark" -Asynchronous
# Node.js
foreach ($version in (Invoke-WebRequest "https://nodejs.org/dist/index.json" -UseBasicParsing | ConvertFrom-Json)) {
	if ($version.lts) {
		$downloads += Start-BitsTransfer -Source "https://nodejs.org/dist/latest-$($version.lts.ToLower())/node-$($version.version)-x64.msi" -Destination node.msi -DisplayName "Node.js" -Asynchronous
		break
	}
}

# PHP
$zips += Start-BitsTransfer -Source "https://windows.php.net/downloads/releases/latest/php-8.0-Win32-vs16-x64-latest.zip" -Destination php.zip -DisplayName "PHP" -Asynchronous
# ADB
$zips += Start-BitsTransfer -Source "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -Destination adb.zip -DisplayName "ADB" -Asynchronous
# Steghide
$zips += Start-BitsTransfer -Source "https://sourceforge.net/projects/steghide/files/latest/download" -Destination steghide.zip -DisplayName "Steghide" -Asynchronous
# Black Cat SSTV
$zips += Start-BitsTransfer -Source "https://www.blackcatsystems.com/download/SSTV_app_windows.zip" -Destination sstv.zip -DisplayName "Black Cat SSTV" -Asynchronous
# Volatility
foreach ($version in ((Invoke-WebRequest https://www.volatilityfoundation.org/releases -UseBasicParsing).Links | Select href)) {
	if ($version -match "win64_standalone.zip") {
		$zips += Start-BitsTransfer -Source $version.href -Destination volatility.zip -DisplayName "Volatility" -Asynchronous
		$volatility_name = $version.href -replace ".*/"
		$volatility_name = $volatility_name.Substring(0, $volatility_name.length - 4)
		break
	}
}

# MongoDB Compass
$version = (Invoke-WebRequest "https://api.github.com/repos/mongodb-js/compass/releases/latest" -UseBasicParsing | ConvertFrom-Json).tag_name
bitsadmin /transfer "MongoDB Compass" /dynamic /download /priority FOREGROUND "https://github.com/mongodb-js/compass/releases/download/$version/mongodb-compass-isolated-$($version.substring(1))-win32-x64.msi" "$home\Downloads\setup\compass.msi"
# JRE
$version = (Invoke-WebRequest "https://api.github.com/repos/AdoptOpenJDK/openjdk8-binaries/releases/latest" -UseBasicParsing | ConvertFrom-Json).tag_name
bitsadmin /transfer "JRE" /dynamic /download /priority FOREGROUND "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/$version/OpenJDK8U-jre_x64_windows_hotspot_$($version.substring(3,5))$($version.substring(9)).msi" "$home\Downloads\setup\openjre.msi"
# VSCodium
foreach ($version in Invoke-WebRequest "https://api.github.com/repos/VSCodium/vscodium/releases/latest" -UseBasicParsing | ConvertFrom-Json | Select -ExpandProperty assets) {
	if ($version.browser_download_url -match "VSCodiumUserSetup-x64") {
		bitsadmin /transfer "VSCodium" /dynamic /download /priority FOREGROUND $version.browser_download_url "$home\Downloads\setup\codium.exe"
		break
	}
}
# gobuster
bitsadmin /transfer "gobuster" /dynamic /download /priority FOREGROUND "https://github.com/OJ/gobuster/releases/latest/download/gobuster-windows-amd64.7z" "$home\Downloads\setup\gobuster.7z"
# ffuf
foreach ($version in Invoke-WebRequest "https://api.github.com/repos/ffuf/ffuf/releases/latest" -UseBasicParsing | ConvertFrom-Json | Select -ExpandProperty assets) {
	if ($version.browser_download_url -match "windows_amd64.zip") {
		bitsadmin /transfer "ffuf" /dynamic /download /priority FOREGROUND $version.browser_download_url "$home\Downloads\ffuf.zip"
		break
	}
}

while (($downloads.JobState -contains "Transferring") -or ($downloads.JobState -contains "Connecting")) {
	clear
	echo $downloads
	echo $zips
	sleep 3
}

clear
echo $downloads
echo $zips
$downloads | Complete-BitsTransfer


Write-Host "Installing Software" -ForegroundColor Green

Write-Host "Extracting HxD"
Expand-Archive hxd.zip -DestinationPath hxd
Write-Host "Starting HxD Installer"
Start-Process hxd/HxDSetup.exe
Write-Host "Starting Nextcloud Installer"
Start-Process nextcloud.exe
Write-Host "Starting VSCodium Installer"
Start-Process -runas $CREDS .\codium.exe

Write-Host "Installing 7-zip"
Start-Process msiexec.exe -Wait -ArgumentList "/i 7z.msi /quiet"
Write-Host "Installing Firefox"
Start-Process msiexec.exe -Wait -ArgumentList "/i firefox.msi /quiet"
Write-Host "Installing Transmission"
Start-Process msiexec.exe -Wait -ArgumentList "/i transmission.msi /quiet"
Write-Host "Installing Wireshark"
Start-Process msiexec.exe -Wait -ArgumentList "/i wireshark.msi /quiet"
Write-Host "Installing Node.js"
Start-Process msiexec.exe -Wait -ArgumentList "/i node.msi /quiet"
Write-Host "Installing MongoDB Compass"
Start-Process msiexec.exe -Wait -ArgumentList "/i compass.msi /quiet"
Write-Host "Installing JRE"
Start-Process msiexec.exe -Wait -ArgumentList "/i openjre.msi /quiet"

if ((Get-WmiObject win32_VideoController).description == "NVIDIA GeForce GTX 1070") {
	Write-Host "Extracting NVIDIA Drivers"
	New-Item -ItemType directory -Path "~\Downloads\setup" -Name "nvidia"
	Set-Location -Path ~\Downloads\setup\nvidia
	& "C:\Program Files\7-Zip\7z.exe" x ..\nvidia.exe
	New-Item -ItemType directory -Path "~\Downloads\setup" -Name "nvidia-install"
	New-Item -ItemType directory -Path "~\Downloads\setup\nvidia-install" -Name "GFExperience"
	Move-Item ("Display.Driver"        ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("Display.Optimus"       ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("NVI2"                  ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("PhysX"                 ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("EULA.txt"              ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("ListDevices.txt"       ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("setup.cfg"             ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("setup.exe"             ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("HDAudio"               ) -Destination "~\Downloads\setup\nvidia-install"
	Move-Item ("PPC"                   ) -Destination "~\Downloads\setup\nvidia-install" -ErrorAction SilentlyContinue
	Move-Item ("GFExperience\PrivacyPolicy"      ) -Destination "~\Downloads\setup\nvidia-install\GFExperience"
	Move-Item ("GFExperience\EULA.html"          ) -Destination "~\Downloads\setup\nvidia-install\GFExperience"
	Move-Item ("GFExperience\FunctionalConsent_*") -Destination "~\Downloads\setup\nvidia-install\GFExperience"
	Set-Location -Path ~\Downloads\setup\nvidia-install
	Start-Process setup.exe -Wait -ArgumentList "-s -noreboot -clean"

	Write-Host "Extracting RTX Voice"
	New-Item -ItemType directory -Path "~\Downloads\setup" -Name "rtx-voice"
	Set-Location -Path ~\Downloads\setup\rtx-voice
	& "C:\Program Files\7-Zip\7z.exe" x ..\rtx-voice.exe
	Start-Process setup.exe -Wait -ArgumentList "-s -noreboot -clean"
	Get-Process "*RTX Voice*" | Stop-Process

	Write-Host "Extracting CUDA"
	New-Item -ItemType directory -Path "~\Downloads\setup" -Name "cuda"
	Set-Location -Path ~\Downloads\setup\cuda
	& "C:\Program Files\7-Zip\7z.exe" x ..\cuda.exe
	Start-Process setup.exe -Wait

	Write-Host "Extracting MSI Afterburner"
	Set-Location -Path ~\Downloads\setup
	Expand-Archive afterburner.zip -DestinationPath afterburner
	Set-Location -Path ~\Downloads\setup\afterburner\*
	Start-Process $(Get-ChildItem)[0].Name

	Set-Location -Path ~\Downloads\setup
}

Write-Host "Installing archives" -ForegroundColor Green
while (($zips.JobState -contains "Transferring") -or ($zips.JobState -contains "Connecting")) {
	clear
	echo $zips
	sleep 3
}
clear
echo $zips
$zips | Complete-BitsTransfer

Write-Host "Installing PHP"
Expand-Archive php.zip -DestinationPath C:\php

Write-Host "Installing ADB"
Expand-Archive adb.zip -DestinationPath adb
Move-Item adb\platform-tools "C:\Program Files\adb"

Write-Host "Installing Steghide"
Expand-Archive steghide.zip -DestinationPath "C:\Program Files"

Write-Host "Installing Black Cat SSTV"
New-Item -ItemType directory -Path "C:\Program Files" -Name "sstv"
Expand-Archive sstv.zip -DestinationPath sstv
Move-Item "sstv\SSTV_app_windows\Black Cat SSTV.exe" "C:\Program Files\sstv"
Move-Item "sstv\SSTV_app_windows\Black Cat SSTV Libs" "C:\Program Files\sstv"
Move-Item "sstv\SSTV_app_windows\Black Cat SSTV Resources" "C:\Program Files\sstv"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Black Cat SSTV.lnk")
$Shortcut.TargetPath = "C:\Program Files\sstv\Black Cat SSTV.exe"
$Shortcut.Save()

Write-Host "Installing gobuster"
& "C:\Program Files\7-Zip\7z.exe" x gobuster.7z
New-Item -ItemType directory -Path "C:\Program Files" -Name "gobuster"
Move-Item "gobuster-windows-amd64\gobuster.exe" "C:\Program Files\gobuster"

Write-Host "Installing ffuf"
Expand-Archive ffuf.zip
New-Item -ItemType directory -Path "C:\Program Files" -Name "ffuf"
Move-Item "ffuf\ffuf.exe" "C:\Program Files\ffuf"

Write-Host "Installing Volatility"
Expand-Archive volatility.zip -DestinationPath volatility
New-Item -ItemType directory -Path "C:\Program Files" -Name "volatility"
Move-Item "volatility\$volatility_name\$volatility_name.exe" "C:\Program Files\volatility\volatility.exe"

Write-Host "Setting PATH"
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Program Files\7-Zip;C:\Program Files\adb;C:\php;C:\Program Files\steghide;C:\Program Files\volatility;C:\Program Files\gobuster;C:\Program Files\ffuf", "Machine")

Write-Host "Uninstalling Software"
Set-Location 'C:\Program Files (x86)\Microsoft\Edge\Application\8*\Installer'
Start-Process setup.exe -ArgumentList "--uninstall --force-uninstall --system-level"
Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage

Write-Host "Arranging Start Menu"
Set-Location "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

Move-Item "MongoDB\MongoDB Compass Isolated Edition.lnk" "."
Move-Item "7-Zip\7-Zip File Manager.lnk" "."
Move-Item "HxD Hex Editor\HxD.lnk" "."

Remove-Item -Recurse "MongoDB"
Remove-Item -Recurse "7-Zip"
Remove-Item -Recurse "HxD Hex Editor"

Set-Location "C:\Users\WDAGUtilityAccount\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"

Move-Item "VSCodium\VSCodium.lnk" "."

Remove-Item -Recurse "VSCodium"

Write-Host "Adding Languages" -ForegroundColor Green
$Languages = Get-WinUserLanguageList
$Languages.add("zh-Hans-CN")
$Languages.add("de-DE")
$Languages.add("ja")
Set-WinUserLanguageList $Languages

New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DisableAcrylicBackgroundOnLogon -Value 1 -PropertyType DWORD

Write-Host "Installing Office" -ForegroundColor Green
Start-BitsTransfer -Source "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12624-20320.exe" -Destination office.exe
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

#Write-Host "Configuring Optional Features" -ForegroundColor Green
#dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
#dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# https://stackoverflow.com/questions/4208694/how-to-speed-up-startup-of-powershell-in-the-4-0-environment
#$env:path = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
#[AppDomain]::CurrentDomain.GetAssemblies() | % {
#  if (! $_.location) {continue}
#  $Name = Split-Path $_.location -leaf
#  Write-Host -ForegroundColor Yellow "NGENing : $Name"
#  ngen install $_.location | % {"`t$_"}
#}

Write-Host "Please reboot your system to finish" -ForegroundColor Green
