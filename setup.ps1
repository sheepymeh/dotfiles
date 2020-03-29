#Requires -RunAsAdministrator

Set-Location -Path $env:temp

Write-Host "Downloading .exe Installers"

Write-Host "Downloading Typora"
Start-BitsTransfer -Source "https://typora.io/windows/typora-setup-x64.exe" -Destination typora.exe
Write-Host "Downloading HxD"
Start-BitsTransfer -Source "https://mh-nexus.de/downloads/HxDSetup.zip" -Destination hxd.zip
Write-Host "Downloading Nextcloud"
Start-BitsTransfer -Source "https://download.nextcloud.com/desktop/releases/Windows/latest" -Destination nextcloud.exe
Write-Host "Downloading VSCodium"
Start-BitsTransfer -Source "https://github.com/VSCodium/vscodium/releases/latest/download/VSCodiumSetup-x64-1.43.1.exe" -Destination codium.exe
foreach ($version in Invoke-WebRequest "https://api.github.com/repos/VSCodium/vscodium/releases/latest" -UseBasicParsing | ConvertFrom-Json | Select -ExpandProperty assets) {
  if ($version.browser_download_url -match "VSCodiumSetup-x64") {
    break;
  }
}
Write-Host "Downloading Git"
foreach ($version in Invoke-WebRequest "https://api.github.com/repos/git-for-windows/git/releases/latest" -UseBasicParsing | ConvertFrom-Json | Select -ExpandProperty assets) {
  if ($version.browser_download_url -match "64-bit.exe") {
    bitsadmin /transfer Git /dynamic /download /priority FOREGROUND $version.browser_download_url "$env:temp\git.exe"
    break;
  }
}
Write-Host "Downloading Audacity"
$audacity_version = (Invoke-WebRequest "https://api.github.com/repos/audacity/audacity/releases/latest" -UseBasicParsing | ConvertFrom-Json).name.split(' ')[1]
# Start-BitsTransfer -Source "https://download.fosshub.com/Protected/expiretime=1585492021;badurl=aHR0cHM6Ly93d3cuZm9zc2h1Yi5jb20vQXVkYWNpdHkuaHRtbA==/2d16eeeeec4cf8b93238eb290f7e5d34bbfbb6d98de533cddf7962ed12d9da3c/5b7eee97e8058c20a7bbfcf4/5dd7e00e1d5d8e08348e2444/audacity-win-2.3.3.exe" -Destination audacity.exe
# ((Invoke-WebRequest 'https://api.fosshub.com/download' -Method POST -Body @{projectId="5b7eee97e8058c20a7bbfcf4";releaseId="5dd7e00e1d5d8e08348e2444";projectUri="Audacity.html";fileName="audacity-win-2.3.3.exe"} -UseBasicParsing).Content | ConvertFrom-Json).data.url
Write-Host "Extracting HxD"
Expand-Archive hxd.zip -DestinationPath hxd

Write-Host "Starting .exe Installers"
Write-Host "Installing Typora"
Start-Process typora.exe
Write-Host "Installing HxD"
Start-Process hxd/HxDSetup.exe
Write-Host "Installing Nextcloud"
Start-Process nextcloud.exe
Write-Host "Installing VSCodium"
Start-Process codium.exe
Write-Host "Installing Git"
Start-Process -FilePath git.exe -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS /NORESTART /CLOSEAPPLICATIONS /TYPE=compact"
# Write-Host "Installing Audacity"
# Start-Process -FilePath audacity.exe -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /MERGETASKS='!desktopicon'"



start /wait audacity-win-2.1.3.exe 

# ((Invoke-WebRequest https://download.gimp.org/pub/gimp -UseBasicParsing).Links | Select href)[-2].href -match "v(?<version>.*)/"

Write-Host "Downloading .msi Installers"

Write-Host "Downloading 7-zip"
Start-BitsTransfer -Source "https://www.7-zip.org/a/7z1900-x64.msi" -Destination 7z.msi
Write-Host "Downloading Firefox"
Start-BitsTransfer -Source "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" -Destination firefox.msi
Write-Host "Downloading ATK"
Start-BitsTransfer -Source "https://dlcdnets.asus.com/pub/ASUS/nb/Apps_for_Win10/ATKPackage/ATK_Package_V100061.zip" -Destination atk.zip
Write-Host "Downloading ASUS Smart Gestures"
Start-BitsTransfer -Source "https://dlcdnets.asus.com/pub/ASUS/nb/Apps_for_Win10/SmartGesture/SmartGesture_Win10_64_VER409.zip" -Destination gesture.zip
Write-Host "Extracting ATK"
Expand-Archive atk.zip -DestinationPath atk
Write-Host "Extracting ASUS Smart Gestures"
Expand-Archive gesture.zip -DestinationPath gesture
Write-Host "Installing 7-zip"
Start-Process msiexec.exe -Wait -ArgumentList "/i 7z.msi /quiet"
Write-Host "Installing Firefox"
Start-Process msiexec.exe -Wait -ArgumentList "/i firefox.msi /quiet"
Write-Host "Installing ATK"
Start-Process msiexec.exe -Wait -ArgumentList "/i atk\data\409.msi /quiet /norestart"
Write-Host "Installing ASUS Smart Gestures"
Start-Process msiexec.exe -Wait -ArgumentList "/i gesture\SetupTPDriver.msi /quiet /norestart"

Write-Host "Downloading ZIPs"
Write-Host "Downloading PHP"
Start-BitsTransfer -Source "https://windows.php.net/downloads/releases/php-7.4.4-Win32-vc15-x64.zip" -Destination php.zip
Write-Host "Downloading ADB"
Start-BitsTransfer -Source "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -Destination adb.zip
Write-Host "Downloading Steghide"
Start-BitsTransfer -Source "https://sourceforge.net/projects/steghide/files/latest/download" -Destination steghide.zip
Write-Host "Downloading Black Cat SSTV"
Start-BitsTransfer -Source "https://www.blackcatsystems.com/download/SSTV_app_windows.zip" -Destination sstv.zip
Write-Host "Downloading Volatility"
foreach ($version in ((Invoke-WebRequest https://www.volatilityfoundation.org/releases -UseBasicParsing).Links | Select href)) {
  if ($version -match "win64_standalone.zip") {
    Start-BitsTransfer -Source $version.href -Destination volatility.zip
    $volatility_name = $version.href -replace '.*/'
    $volatility_name = $volatility_name.Substring(0, $volatility_name.length - 4)
    break;
  }
}
Write-Host "Expanding PHP"
Expand-Archive php.zip -DestinationPath C:\php
Write-Host "Expanding ADB"
Expand-Archive adb.zip -DestinationPath adb
New-Item -ItemType directory -Path "C:\Program Files" -Name "adb"
Move-Item adb/platform-tools "C:\Program Files\adb"
Write-Host "Expanding Steghide"
New-Item -ItemType directory -Path "C:\Program Files" -Name "steghide"
Expand-Archive steghide.zip -DestinationPath steghide
Move-Item steghide/steghide "C:\Program Files\steghide"
Write-Host "Expanding Volatility"
Expand-Archive volatility.zip -DestinationPath volatility
New-Item -ItemType directory -Path "C:\Program Files" -Name "volatility"
Move-Item "volatility\$volatility_name\$volatility_name.exe" "C:\Program Files\volatility\volatility.exe"
Write-Host "Expanding Black Cat SSTV"
New-Item -ItemType directory -Path "C:\Program Files" -Name "sstv"
Expand-Archive sstv.zip -DestinationPath sstv
Move-Item "sstv/SSTV_app_windows/Black Cat SSTV.exe" "C:\Program Files\sstv"
Move-Item "sstv/SSTV_app_windows/Black Cat SSTV Libs" "C:\Program Files\sstv"
Move-Item "sstv/SSTV_app_windows/Black Cat SSTV Resources" "C:\Program Files\sstv"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Black Cat SSTV.lnk")
$Shortcut.TargetPath = "C:\Program Files\sstv\Black Cat SSTV.exe"
$Shortcut.Save()

Write-Host "Setting PATH"
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Program Files\7-Zip;C:\Program Files\adb;C:\php;C:\Program Files\steghide;C:\Program Files\volatility", "Machine")

Write-Host "Downloading Fonts"
Write-Host "Downloading JetBrains Mono"
Start-BitsTransfer -Source "https://download.jetbrains.com/fonts/JetBrainsMono-1.0.3.zip" -Destination jetbrains.zip
Expand-Archive jetbrains.zip -DestinationPath jetbrains
Write-Host "Downloading Inter"
Start-BitsTransfer -Source "https://github.com/rsms/inter/releases/download/v3.12/Inter-3.12.zip" -Destination inter.zip
Expand-Archive inter.zip -DestinationPath inter

Write-Host "Adding Languages"
$Languages = Get-WinUserLanguageList
$Languages.add("zh-Hans-CN")
$Languages.add("de-DE")
$Languages.add("ja")
Set-WinUserLanguageList $Languages

New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name DisableAcrylicBackgroundOnLogon -Value 1 -PropertyType DWORD

Write-Host "Installing Office"
Set-Content -Path 'office.xml' -Value @'<Configuration ID="b52a1db2-5c63-4902-b071-ef2ea1b0d347">
  <Add OfficeClientEdition="64" Channel="Monthly">
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
    </Product>
    <Product ID="ProofingTools">
      <Language ID="zh-cn" />
      <Language ID="de-de" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>'@

Start-BitsTransfer -Source "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117" -Destination office.exe

Start-Process office.exe -Wait -ArgumentList "/download office.xml"