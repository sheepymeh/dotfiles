#Requires -RunAsAdministratorClear-Host
$Host.UI.RawUI.WindowTitle = 'Windows 10 Sophia Script | Copyright farag & oZ-Zo, 2015 to 2021'
Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\Sophia.psd1 -PassThru -Force
Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia
Checkings

# System Protection


# Privacy & Telemetry

DiagTrackService -Disable
ErrorReporting -Disable
WindowsFeedback -Disable
ScheduledTasks -Disable
SigninInfo -Disable
LanguageListAccess -Disable
AdvertisingID -Disable
ShareAcrossDevices -Disable
WindowsWelcomeExperience -Hide
WindowsTips -Disable
SettingsSuggestedContent -Hide
AppsSilentInstalling -Disable
WhatsNewInWindows -Disable
TailoredExperiences -Disable
BingSearch -Disable

# UI and Personalization

CheckBoxes -Disable
FileExtensions -Show
MergeConflicts -Show
OpenFileExplorerTo -ThisPC
CortanaButton -Hide
OneDriveFileExplorerAd -Hide
TaskViewButton -Hide
3DObjects -Hide
QuickAccessFrequentFolders -Hide
QuickAccessRecentFiles -Hide
WindowsInkWorkspace -Hide
TrayIcons -Hide
UnpinTaskbarEdgeStore
WindowsColorScheme -Dark
AppMode -Dark
NewAppInstalledNotification -Hide
JPEGWallpapersQuality -Max
RestartNotification -Show
ShortcutsSuffix -Disable
PrtScnSnippingTool -Enable

# OneDrive

OneDrive -Uninstall

# System

StorageSense -Enable
StorageSenseRecycleBin -Enable
Hibernate -Disable
Win32LongPathLimit -Disable
BSoDStopError -Enable
DeliveryOptimization -Disable
WindowsFeatures -Disable
WindowsCapabilities -Uninstall
UpdateMicrosoftProducts -Enable
F1HelpPage -Disable
NumLock -Enable
StickyShift -Disable
Autoplay -Disable
SaveRestartableApps -Disable
NetworkDiscovery -Disable

# Start

RecentlyAddedApps -Hide
AppSuggestions -Hide
PinToStart -UnpinAll

# UWP

UninstallUWPApps
HEIF -Manual

# Gaming

XboxGameBar -Disable
XboxGameTips -Disable

# Scheduled


# Defender & Security

DismissMSAccount
DismissSmartScreenFilter
AppsSmartScreen -Disable
WindowsScriptHost -Disable

# Context

CastToDeviceContext -Hide
ShareContext -Hide
EditWithPaint3DContext -Hide
CreateANewVideoContext -Hide
PrintCMDContext -Hide
IncludeInLibraryContext -Hide
SendToContext -Hide
BitLockerContext -Hide
BitmapImageNewContext -Remove
RichTextDocumentNewContext -Remove
CompressedFolderNewContext -Remove
MultipleInvokeContext -Enable
UseStoreOpenWith -Hide
PreviousVersionsPage -Hide

# Other

TaskbarSearch -Hide

Refresh
Errors
