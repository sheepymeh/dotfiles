#!/bin/zsh
set -euo pipefail

# https://www.alfredapp.com/help/troubleshooting/indexing/terminal-full-disk-access/
cd "$(dirname -- "$0")"
. ../posix-common/config.sh

sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local > /dev/null


open sheepymeh.mobileconfig
curl -o /tmp/adguard_dns.mobileconfig "https://adguard-dns.io$(curl 'https://adguard-dns.io/public_api/v1/dns/mobile_config' \
  --json '{"dns_proto_type":"DOT","filtering_type":"DEFAULT","exclude_wifi_networks":[""],"exclude_domain":[""]}' | jq -r '.download_link')"
open /tmp/adguard_dns.mobileconfig

source <(curl https://gist.githubusercontent.com/kamui545/c810eccf6281b33a53e094484247f5e8/raw/c4f32fd8ed4bea9629b84b2858357d735192c75a/dock_functions.sh)
declare -a DOCK_APPS=(
	'/Applications/Firefox.app'
	'/System/Applications/Calendar.app'
	'/System/Applications/Mail.app'
	'/Applications/Visual Studio Code.app'
	'/System/Applications/Utilities/Terminal.app'
);
clear_dock
disable_recent_apps_from_dock
for app in "${DOCK_APPS[@]}"; do
	add_app_to_dock "$app"
done
add_folder_to_dock "$HOME/Downloads" -a 2 -d 1 -v 2


NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off
brew update


eval "$(/opt/homebrew/bin/brew shellenv)"
brew install --yes basictex bazelisk bitwarden middleclick music-decoy owncloud pygments python@3 ruff shellcheck signal uv verilator visual-studio-code zed firefox


add_login_item () {
	osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/$1.app\", hidden:true}"
}

add_login_item "Music Decoy"
add_login_item "MiddleClick"


eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sudo tlmgr install \
	collection-binextra \
	collection-fontsrecommended \
	collection-latex \
	collection-latexrecommended \
	collection-latexextra \
	collection-mathscience \
	collection-plaingeneric \
	collection-bibtexextra \
	collection-pictures \
	collection-publishers \
	minted \
	latexmk \
	biber


sudo pmset -a womp 0

NEW_HOSTNAME="koito"
sudo scutil --set ComputerName "$NEW_HOSTNAME"
sudo scutil --set LocalHostName "$NEW_HOSTNAME"
sudo scutil --set HostName "$NEW_HOSTNAME"
dscacheutil -flushcache


osascript -e 'tell application "System Events" to tell appearance preferences' \
	-e 'set recent documents limit to 15' \
	-e 'set recent applications limit to 15' \
	-e 'set recent servers limit to 15' \
	-e 'end tell'

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock orientation left
defaults write com.apple.dock tilesize -int 32
# put display to sleep
defaults write com.apple.dock wvous-bl-corner -int 10
# no modifier key
defaults write com.apple.dock wvous-bl-modifier -int 0
# show desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

defaults write com.apple.chronod RemoteWidgetsEnabled -bool false
defaults write com.apple.WindowManager StandardHideWidgets -bool true

osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
defaults write -g AppleAccentColor -int 5  # purple
defaults write -g AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"

defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write NSGlobalDomain NSRecentDocumentsLimit 0
defaults write com.apple.finder ShowRecentTags -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2

defaults write com.apple.HIToolbox AppleFnUsageType -int 1
defaults write -g AppleKeyboardUIMode -int 2
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If found, please email me at jiayang@tuta.io"

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.trackpad.scaling -float 1.5
defaults write -g com.apple.mouse.scaling -float 1.5
defaults write -g com.apple.mouse.doubleClickThreshold -float 0.3

defaults -currentHost write com.apple.controlcenter Spotlight -int 8
defaults -currentHost write com.apple.controlcenter ShowSuggestions -bool false
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Keyboard settings
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticInlinePredictionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

defaults write com.apple.iCal "display birthdays calendar" -bool true
defaults write com.apple.iCal "number of hours displayed" -int 16
defaults write com.apple.iCal "Show Week Numbers" -bool true
defaults write com.apple.iCal "TimeZone support enabled" -bool true
defaults write com.apple.iCal CALPrefOverlayCalendarIdentifier -string chinese
defaults write com.apple.iCal DefaultAllDayAlarmOffset -int 32400
defaults write com.apple.iCal DefaultTimedAlarmOffset -int 0
defaults write com.apple.iCal enableTravelAdvisoriesForAutomaticBehavior -bool false

defaults write -g AppleICUForce24HourTime -bool true
sudo defaults write /Library/Preferences/.GlobalPreferences AppleICUForce24HourTime -bool true
sudo sysadminctl -use12HourClockForLoginWindow off

killall Dock Finder ControlCenter SystemUIServer cfprefsd


git_config

firefox_config /Applications/Firefox.app/Contents/Resources/distribution Library/Application\ Support/Firefox/Profiles
jq 'del(.policies.Preferences."browser.tabs.inTitlebar")' "/Applications/Firefox.app/Contents/Resources/distribution/policies.json" > /tmp/ff-settings.json
mv /tmp/ff-settings.json "/Applications/Firefox.app/Contents/Resources/distribution/policies.json"
sed -i '' '/font\.name/d' ~/Library/Application\ Support/Firefox/Profiles/*.default-release/user.js

vscode_config "Library/Application Support/Code/User"
jq 'del(."window.titleBarStyle", ."update.mode")' "$HOME/Library/Application Support/Code/User/settings.json" > /tmp/vsc-settings.json
mv /tmp/vsc-settings.json "$HOME/Library/Application Support/Code/User/settings.json"
vscode_install_ext code

cp ../config/ownCloud/sync-exclude.lst ~/Library/Preferences/ownCloud

cp zprofile.sh "$HOME/.zprofile"
