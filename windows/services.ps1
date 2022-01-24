# Adapted from https://www.briteccomputers.co.uk/posts/disable-unnecessary-services-in-windows-10-in-2021-2/

# Application Layer Gateway Service
Set-Service -Name ALG -StartupType disabled
# AllJoyn Router Service
Set-Service -Name AJRouter -StartupType disabled
# Xbox Live Auth Manager
Set-Service -Name XblAuthManager -StartupType disabled
# Xbox Live Game Save
Set-Service -Name XblGameSave -StartupType disabled
# Xbox Live Networking Service
Set-Service -Name XboxNetApiSvc -StartupType disabled
# Geolocation Service
Set-Service -Name lfsvc -StartupType disabled
# Remote Registry
Set-Service -Name RemoteRegistry -StartupType disabled
# Parental Control
Set-Service -Name WpcMonSvc -StartupType disabled
# Payments and NFC/SE Manager
Set-Service -Name SEMgrSvc -StartupType disabled
# Smartcard
Set-Service -Name SCardSvr -StartupType disabled
# Netlogon
Set-Service -Name Netlogon -StartupType disabled
# Offline Files
Set-Service -Name CscService -StartupType disabled
# Windows Mobile Hotspot Service
Set-Service -Name icssvc -StartupType disabled
# Windows Insider Service
Set-Service -Name wisvc -StartupType disabled
# Retail Demo Service
Set-Service -Name RetailDemo -StartupType disabled
# WalletService
Set-Service -Name WalletService -StartupType disabled
# Fax
Set-Service -Name Fax -StartupType disabled
# Windows Biometric Service
Set-Service -Name WbioSrvc -StartupType disabled
# Windows Connect Now
Set-Service -Name wcncsvc -StartupType disabled
# File History Service
Set-Service -Name fhsvc -StartupType disabled
# Phone Service
Set-Service -Name PhoneSvc -StartupType disabled
# Secondary Logon
Set-Service -Name seclogon -StartupType disabled
# Windows Biometric Service
Set-Service -Name WbioSrvc -StartupType disabled
# Windows Image Acquisition
Set-Service -Name StiSvc -StartupType disabled
# Program Compatibility Assistant Service
Set-Service -Name PcaSvc -StartupType disabled
# Diagnostic Policy Service
Set-Service -Name DPS -StartupType disabled
# Download Maps Manager
Set-Service -Name MapsBroker -StartupType disabled
# Bluetooth Support Service
Set-Service -Name bthserv -StartupType disabled
# AVCTP Service
Set-Service -Name BthAvctpSvc -StartupType disabled
# Parental Control
Set-Service -Name WpcMonSvc -StartupType disabled
# Connected User Experience and Telemetry
Set-Service -Name DiagTrack -StartupType disabled
# Diagnostic Service Host
Set-Service -Name WdiServiceHost -StartupType disabled
# TCP/IP NetBIOS Helper
Set-Service -Name lmhosts -StartupType disabled
# Diagnostic System Host
Set-Service -Name WdiSystemHost -StartupType disabled
# Windows Error Reporting Service
Set-Service -Name WerSvc -StartupType disabled
# GameDVR and Broadcast
Set-Service -Name BcastDVRUserService -StartupType disabled
# Windows Media Player Network Sharing Service
Set-Service -Name WMPNetworkSvc -StartupType disabled
# Microsoft Diagnostics Hub Standard Collector Service
Set-Service -Name diagnosticshub.standardcollector.service -StartupType disabled
# Device Management Enrollment Service
Set-Service -Name DmEnrollmentSvc -StartupType disabled
# PNRP Machine Name Publication Service
Set-Service -Name PNRPAutoReg -StartupType disabled
# Microsoft Account Sign-in Assistant
Set-Service -Name wlidsvc -StartupType disabled
# ActiveX Installer
Set-Service -Name AXInstSV -StartupType disabled
