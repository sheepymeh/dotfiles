#Requires -RunAsAdministrator
#Requires -Version 5.1

Clear-Host

Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name .\Sophia.psd1 -PassThru -Force

Import-LocalizedData -BindingVariable Global:Localization

# Checking
Check

# Disable the "Connected User Experiences and Telemetry" service (DiagTrack)
DisableTelemetryServices

# Set the OS level of diagnostic data gathering to minimum
# SetMinimalDiagnosticDataLevel

# Turn off Windows Error Reporting for the current user
DisableWindowsErrorReporting

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

# Do not get tip, trick, and suggestions as you use Windows (current user only)
# DisableWindowsTips

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

# Do not show when snapping a window, what can be attached next to it (current user only)
DisableSnapAssist

# Always open the file transfer dialog box in the detailed mode (current user only)
FileTransferDialogDetailed

# Display recycle bin files delete confirmation
EnableRecycleBinDeleteConfirmation

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

# Start Task Manager in expanded mode (current user only)
TaskManagerWindowExpanded

# Show a notification when your PC requires a restart to finish updating
ShowRestartNotification

# Do not add the "- Shortcut" suffix to the file name of created shortcuts (current user only)
# DisableShortcutsSuffix

# Use the PrtScn button to open screen snipping (current user only)
EnablePrtScnSnippingTool

# Uninstall OneDrive
UninstallOneDrive

# Enable Windows 260 character path limit
# EnableWin32LongPaths

# Disable Windows 260 character path limit
# DisableWin32LongPaths

# Display the Stop error information on the BSoD
# EnableBSoDStopError

# Opt out of the Delivery Optimization-assisted updates downloading
DisableDeliveryOptimization

# Disable the following Windows features
DisableWindowsFeatures

<#
	Download and install the Linux kernel update package
	Set WSL 2 as the default version when installing a new Linux distribution
	Run the function only after WSL installed and PC restart

	https://github.com/microsoft/WSL/issues/5437
#>
SetupWSL

<#
	Disable swap file in WSL
	Use only if the %TEMP% environment variable path changed

	https://github.com/microsoft/WSL/issues/5437
#>
DisableWSLSwap

<#
	Enable swap file in WSL

	https://github.com/microsoft/WSL/issues/5437
#>
EnableWSLSwap

# Disable certain Feature On Demand v2 (FODv2) capabilities
DisableWindowsCapabilities

# Opt-in to Microsoft Update service, so to receive updates for other Microsoft products
EnableUpdatesMicrosoftProducts

# Enable Windows Sandbox
# Включить Windows Sandbox
EnableWindowsSandbox

# Disable help lookup via F1 (current user only)
DisableF1HelpPage

# Turn on Num Lock at startup
# Включить Num Lock при загрузке
EnableNumLock

# Do not activate StickyKey after tapping the Shift key 5 times (current user only)
# Не включать залипание клавиши Shift после 5 нажатий (только для текущего пользователя)
DisableStickyShift

# Do not use AutoPlay for all media and devices (current user only)
DisableAutoplay

# Disable thumbnail cache removal
DisableThumbnailCacheRemoval

# Enable thumbnail cache removal
# Включить удаление кэша миниатюр
# EnableThumbnailCacheRemoval

# Do not show recently added apps in the Start menu
HideRecentlyAddedApps

# Do not show app suggestions in the Start menu
HideAppSuggestions

# Unpin all the Start tiles
UnpinAllStartTiles

#region UWP apps
<#
	Uninstall UWP apps
	A dialog box that enables the user to select packages to remove
	App packages will not be installed for new users if "Uninstall for All Users" is checked
#>
UninstallUWPApps

<#
	Open Microsoft Store "HEVC Video Extensions from Device Manufacturer" page
	The extension can be installed without Microsoft account for free instead of $0.99
	"Movies & TV" app required
#>
InstallHEVC

# Turn off Cortana autostarting
DisableCortanaAutostart

# Check for UWP apps updates
CheckUWPAppsUpdates

#region Gaming
# Turn off Xbox Game Bar
DisableXboxGameBar

# Turn off Xbox Game Bar tips
DisableXboxGameTips

# Dismiss Microsoft Defender offer in the Windows Security about signing in Microsoft account
DismissMSAccount

# Dismiss Microsoft Defender offer in the Windows Security about turning on the SmartScreen filter for Microsoft Edge
# DismissSmartScreenFilter

# Turn on events auditing generated when a process is created or starts
# EnableAuditProcess

# Turn off Windows Script Host (current user only)
# Отключить Windows Script Host (только для текущего пользователя)
DisableWindowsScriptHost

# Add the "Install" item to the .cab archives context menu
AddCABInstallContext

# Hide the "Cast to Device" item from the context menu
HideCastToDeviceContext

# Hide the "Share" item from the context menu
HideShareContext

# Hide the "Edit with Paint 3D" item from the context menu
HideEditWithPaint3DContext

# Hide the "Edit with Photos" item from the context menu
HideEditWithPhotosContext

# Hide the "Create a new video" item from the context menu
HideCreateANewVideoContext

# Hide the "Edit" item from the images context menu
HideImagesEditContext

# Hide the "Print" item from the .bat and .cmd context menu
HidePrintCMDContext

# Hide the "Include in Library" item from the context menu
HideIncludeInLibraryContext

# Hide the "Send to" item from the folders context menu
HideSendToContext

# Hide the "Turn on BitLocker" item from the context menu
HideBitLockerContext

# Remove the "Bitmap image" item from the "New" context menu
RemoveBitmapImageNewContext

# Remove the "Rich Text Document" item from the "New" context menu
RemoveRichTextDocumentNewContext

# Remove the "Compressed (zipped) Folder" item from the "New" context menu
RemoveCompressedFolderNewContext

# Make the "Open", "Print", and "Edit" context menu items available, when more than 15 items selected
EnableMultipleInvokeContext

# Hide the "Look for an app in the Microsoft Store" item in the "Open with" dialog
DisableUseStoreOpenWith

# Hide the "Previous Versions" tab from files and folders context menu and also the "Restore previous versions" context menu item
DisablePreviousVersionsPage

Refresh

# Errors output
Errors