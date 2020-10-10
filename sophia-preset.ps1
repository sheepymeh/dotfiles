#Requires -RunAsAdministrator
#Requires -Version 5.1

Clear-Host

Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name .\Sophia.psd1 -PassThru -Force

Import-LocalizedData -BindingVariable Global:Localization

# Checking
# Проверка
Check

# Disable the "Connected User Experiences and Telemetry" service (DiagTrack)
DisableTelemetryServices

# Set the OS level of diagnostic data gathering to minimum
# SetMinimalDiagnosticDataLevel

# Turn off Windows Error Reporting for the current user
# DisableWindowsErrorReporting

# Change Windows feedback frequency to "Never" for the current user
DisableWindowsFeedback

# Turn off diagnostics tracking scheduled tasks
DisableScheduledTasks

# Do not use sign-in info to automatically finish setting up device and reopen apps after an update or restart (current user only)
DisableSigninInfo

# Do not let websites provide locally relevant content by accessing language list (current user only)
DisableLanguageListAccess

# Do not allow apps to use advertising ID (current user only)
DisableAdvertisingID

# Do not let apps on other devices open and message apps on this device, and vice versa (current user only)
DisableShareAcrossDevices

# Do not show the Windows welcome experiences after updates and occasionally when I sign in to highlight what's new and suggested (current user only)
DisableWindowsWelcomeExperience

# Do not show suggested content in the Settings app (current user only)
DisableSuggestedContent

# Turn off automatic installing suggested apps (current user only)
DisableAppsSilentInstalling

# Do not suggest ways I can finish setting up my device to get the most out of Windows (current user only)
DisableWhatsNewInWindows

# Do not offer tailored experiences based on the diagnostic data setting (current user only)
DisableTailoredExperiences

# Disable Bing search in the Start Menu
DisableBingSearch

# Do not use check boxes to select items (current user only)
DisableCheckBoxes

# Show hidden files, folders, and drives (current user only)
# ShowHiddenItems

# Show file name extensions (current user only)
ShowFileExtensions

# Do not hide folder merge conflicts (current user only)
ShowMergeConflicts

# Open File Explorer to: "This PC" (current user only)
OpenFileExplorerToThisPC

# Do not show Cortana button on the taskbar (current user only)
HideCortanaButton

# Do not show sync provider notification within File Explorer (current user only)
HideOneDriveFileExplorerAd

# Do not show Task View button on the taskbar (current user only)
HideTaskViewButton

# Do not show People button on the taskbar (current user only)
HidePeopleTaskbar

# Hide the "3D Objects" folder from "This PC" and "Quick access" (current user only)
Hide3DObjects

# Do not show frequently used folders in "Quick access" (current user only)
HideQuickAccessFrequentFolders

# Do not show recently used files in Quick access (current user only)
HideQuickAccessRecentFiles

# Hide the search box or the search icon from the taskbar (current user only)
HideTaskbarSearch

# Do not show the "Windows Ink Workspace" button on the taskbar (current user only)
HideWindowsInkWorkspace

# Unpin "Microsoft Edge" and "Microsoft Store" from the taskbar (current user only)
UnpinTaskbarEdgeStore

# Set the Windows mode color scheme to the dark (current user only)
WindowsColorSchemeDark

# Set the default app mode color scheme to the dark (current user only)
AppModeDark

# Do not show the "New App Installed" indicator
DisableNewAppInstalledNotification

# Do not show user first sign-in animation after the upgrade
HideFirstSigninAnimation

# Set the quality factor of the JPEG desktop wallpapers to maximum (current user only)
JPEGWallpapersQualityMax

# Show a notification when your PC requires a restart to finish updating
ShowRestartNotification

# Do not add the "- Shortcut" suffix to the file name of created shortcuts (current user only)
# DisableShortcutsSuffix

# Use the PrtScn button to open screen snipping (current user only)
EnablePrtScnSnippingTool

# Disable hibernation if the device is not a laptop
DisableHibernate

# Change the %TEMP% environment variable path to the %SystemDrive%\Temp (both machine-wide, and for the current user)
SetTempPath

# Enable Windows 260 character path limit
# EnableWin32LongPaths

# Display the Stop error information on the BSoD
# EnableBSoDStopError

# Turn on access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled
EnableMappedDrivesAppElevatedAccess

# Disable help lookup via F1 (current user only)
DisableF1HelpPage

# Turn on Num Lock at startup
EnableNumLock