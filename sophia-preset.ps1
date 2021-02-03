#Requires -RunAsAdministrator
#Requires -Version 5.1

Clear-Host

Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name .\Sophia.psd1 -PassThru -Force

Import-LocalizedData -BindingVariable Global:Localization

# Checking
Check

# Disable the "Connected User Experiences and Telemetry" service (DiagTrack)
TelemetryService -Disable

# Set the OS level of diagnostic data gathering to minimum
# DiagnosticDataLevel -Minimal

# Turn off Windows Error Reporting for the current user
# ErrorReporting -Disable

# Change Windows feedback frequency to "Never" for the current user
WindowsFeedback -Disable

# Turn off diagnostics tracking scheduled tasks
ScheduledTasks -Disable

# Do not use sign-in info to automatically finish setting up device and reopen apps after an update or restart (current user only)
SigninInfo -Disable

# Do not allow apps to use advertising ID (current user only)
AdvertisingID -Disable

# Do not let apps on other devices open and message apps on this device, and vice versa (current user only)
ShareAcrossDevices -Disable

# Do not show the Windows welcome experiences after updates and occasionally when I sign in to highlight what's new and suggested (current user only)
WindowsWelcomeExperience -Hide

# Do not get tip, trick, and suggestions as you use Windows (current user only)
# WindowsTips -Diable

# Do not show suggested content in the Settings app (current user only)
SettingsSuggestedContent -Hide

# Turn off automatic installing suggested apps (current user only)
AppsSilentInstalling -Disable

# Do not suggest ways I can finish setting up my device to get the most out of Windows (current user only)
WhatsNewInWindows -Disable

# Do not offer tailored experiences based on the diagnostic data setting (current user only)
TailoredExperiences -Disable

# Disable Bing search in the Start Menu
BingSearch -Disable

# Do not use check boxes to select items (current user only)
CheckBoxes -Disable

# Show hidden files, folders, and drives (current user only)
# HiddenItems -Enable

# Show file name extensions (current user only)
FileExtensions -Show

# Do not hide folder merge conflicts (current user only)
MergeConflicts -Show

# Open File Explorer to: "This PC" (current user only)
OpenFileExplorerTo -ThisPC

# Do not show Cortana button on the taskbar (current user only)
CortanaButton -Hide

# Do not show sync provider notification within File Explorer (current user only)
OneDriveFileExplorerAd -Hide

# Do not show Task View button on the taskbar (current user only)
TaskViewButton -Hide

# Do not show People button on the taskbar (current user only)
PeopleTaskbar -Hide

# Do not show when snapping a window, what can be attached next to it (current user only)
# SnapAssist -Hide

# Always open the file transfer dialog box in the detailed mode (current user only)
FileTransferDialog -Detailed

# Display recycle bin files delete confirmation
RecycleBinDeleteConfirmation -Disable

# Hide the "3D Objects" folder from "This PC" and "Quick access" (current user only)
3DObjects -Hide

# Do not show frequently used folders in "Quick access" (current user only)
QuickAccessFrequentFolders -Hide

# Do not show recently used files in Quick access (current user only)
QuickAccessRecentFiles -Hide

# Hide the search box or the search icon from the taskbar (current user only)
TaskbarSearch -Hide

# Do not show the "Windows Ink Workspace" button on the taskbar (current user only)
WindowsInkWorkspace -Hide

# Unpin "Microsoft Edge" and "Microsoft Store" from the taskbar (current user only)
UnpinTaskbarEdgeStore

# Set the Windows mode color scheme to the dark (current user only)
WindowsColorScheme -Dark

# Set the default app mode color scheme to the dark (current user only)
AppMode -Dark

# Do not show the "New App Installed" indicator
NewAppInstalledNotification -Hide

# Do not show user first sign-in animation after the upgrade
# FirstLogonAnimation -Disable

# Set the quality factor of the JPEG desktop wallpapers to maximum (current user only)
JPEGWallpapersQualityMax

# Start Task Manager in expanded mode (current user only)
TaskManagerWindow -Expanded

# Show a notification when your PC requires a restart to finish updating
RestartNotification -Show

# Do not add the "- Shortcut" suffix to the file name of created shortcuts (current user only)
ShortcutsSuffix -Disable

# Use the PrtScn button to open screen snipping (current user only)
PrtScnSnippingTool -Enable

# Uninstall OneDrive
UninstallOneDrive

# Disable Windows 260 character path limit
Win32LongPathLimit -Disable

# Display the Stop error information on the BSoD
BSoDStopError -Enable

# Opt out of the Delivery Optimization-assisted updates downloading
DeliveryOptimization -Disable

# Disable the following Windows features
WindowsFeatures -Disable


<#
	Download and install the Linux kernel update package
	Set WSL 2 as the default version when installing a new Linux distribution
	Run the function only after WSL installed and PC restart

	https://github.com/microsoft/WSL/issues/5437
#>
#WSL -Enable
#EnableWSL2

<#
	Disable swap file in WSL
	Use only if the %TEMP% environment variable path changed

	https://github.com/microsoft/WSL/issues/5437
#>
#WSLSwap -Disable

# Disable certain Feature On Demand v2 (FODv2) capabilities
WindowsCapabilities -Disable

# Opt-in to Microsoft Update service, so to receive updates for other Microsoft products
UpdateMicrosoftProducts -Enable

# Enable Windows Sandbox
# Включить Windows Sandbox
WindowsSandbox -Enable

# Disable help lookup via F1 (current user only)
F1HelpPage -Disable

# Turn on Num Lock at startup
# Включить Num Lock при загрузке
NumLock -Enable

# Do not activate StickyKey after tapping the Shift key 5 times (current user only)
# Не включать залипание клавиши Shift после 5 нажатий (только для текущего пользователя)
StickyShift -Disable

# Do not use AutoPlay for all media and devices (current user only)
Autoplay -Disable

# Do not show recently added apps in the Start menu
RecentlyAddedApps -Hide

# Do not show app suggestions in the Start menu
AppSuggestions -Hide

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
CortanaAutostart -Disable

# Check for UWP apps updates
CheckUWPAppsUpdates

#region Gaming
# Turn off Xbox Game Bar
XboxGameBar -Disable

# Turn off Xbox Game Bar tips
XboxGameTips -Disable

# Dismiss Microsoft Defender offer in the Windows Security about signing in Microsoft account
DismissMSAccount

# Dismiss Microsoft Defender offer in the Windows Security about turning on the SmartScreen filter for Microsoft Edge
# DismissSmartScreenFilter

# Turn on events auditing generated when a process is created or starts
# EnableAuditProcess

# Turn off Windows Script Host (current user only)
# Отключить Windows Script Host (только для текущего пользователя)
WindowsScriptHost -Disable

# Add the "Install" item to the .cab archives context menu
CABInstallContext -Add

# Hide the "Cast to Device" item from the context menu
CastToDeviceContext -Hide

# Hide the "Share" item from the context menu
ShareContext -Hide

# Hide the "Edit with Paint 3D" item from the context menu
EditWithPaint3DContext -Hide

# Hide the "Edit with Photos" item from the context menu
EditWithPhotosContext -Hide

# Hide the "Create a new video" item from the context menu
CreateANewVideoContext -Hide

# Hide the "Edit" item from the images context menu
ImagesEditContext -Hide

# Hide the "Print" item from the .bat and .cmd context menu
PrintCMDContext -Hide

# Hide the "Include in Library" item from the context menu
IncludeInLibraryContext -Hide

# Hide the "Send to" item from the folders context menu
SendToContext -Hide

# Hide the "Turn on BitLocker" item from the context menu
BitLockerContext -Hide

# Remove the "Bitmap image" item from the "New" context menu
BitmapImageNewContext -Remove

# Remove the "Rich Text Document" item from the "New" context menu
RichTextDocumentNewContext -Remove

# Remove the "Compressed (zipped) Folder" item from the "New" context menu
CompressedFolderNewContext -Remove

# Make the "Open", "Print", and "Edit" context menu items available, when more than 15 items selected
MultipleInvokeContext -Enable

# Hide the "Look for an app in the Microsoft Store" item in the "Open with" dialog
UseStoreOpenWith -Hide

# Hide the "Previous Versions" tab from files and folders context menu and also the "Restore previous versions" context menu item
PreviousVersionsPage -Hide

Refresh

# Errors output
Errors