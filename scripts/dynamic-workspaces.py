#!/usr/bin/python
# pyright: reportUnusedCallResult=false

# This script requires i3ipc-python package (install it from a system package manager
# or pip).
# It adds icons to the workspace name for each open window.
# Set your keybindings like this: set $workspace1 workspace number 1
# Add your icons to WINDOW_ICONS.
# Based on https://github.com/OctopusET/sway-contrib/blob/master/autoname-workspaces.py

from typing import ClassVar, Final, override
import re
from dataclasses import dataclass

import i3ipc

DEFAULT_ICON: Final[str] = ""
XWAYLAND_ICON: Final[str] = ""
WINDOW_ICONS: Final[dict[str, str]] = {
    # Editors
    "code": "󰨞",
    "code-oss": "󰨞",
    "code-url-handler": "󰨞",
    "codium": "󰨞",
    "codium-url-handler": "󰨞",
    "dev.zed.Zed": "",
    "jetbrains-clion": "",
    "jetbrains-datagrip": "",
    "jetbrains-goland": "󰟓",
    "jetbrains-idea": "",
    "jetbrains-phpstorm": "",
    "jetbrains-pycharm": "",
    "jetbrains-rustrover": "",
    "jetbrains-webstorm": "",
    # Office
    "libreoffice": "",
    "libreoffice-startcenter": "",
    "libreoffice-base": "",
    "libreoffice-calc": "",
    "libreoffice-draw": "",
    "libreoffice-impress": "",
    "libreoffice-math": "",
    "libreoffice-writer": "",
    "org.gnome.papers": "",
    # Terminals
    "alacritty": "",
    "foot": "",
    "footclient": "",
    "kitty": "",
    # Other
    "anki": "",
    "blueman-manager": "",
    "cafe.avery.Delfin": "",
    "chromium": "",
    "com.nextcloud.desktopclient.nextcloud": "",
    "com.transmissionbt.transmission_64768_1591335": "󰛴",
    "desktopclient.owncloud.com.owncloud": "",
    "owncloud": "",
    "engrampa": "",
    "firefox": "",
    "imv": "",
    "io.missioncenter.missioncenter": "",
    "mpv": "",
    "nwg-displays": "",
    "org.kde.krita": "",
    "org.mozilla.thunderbird": "",
    "org.pulseaudio.pavucontrol": "",
    "pavucontrol": "",
    "signal": "󰭹",
    "system-config-printer": "",
    "thunar": "",
    "thunar-volman-settings": "",
    "virt-manager": "󰍺",
    "wdisplays": "",
    "wine": "",
}


@dataclass
class Window:
    ipc_data: dict[str, str]
    app_id: str | None
    window_class: str | None


@dataclass
class WorkspaceNameParts:
    num: str
    shortname: str | None
    icons: str | None

    @override
    def __str__(self) -> str:
        new_name = self.num
        if self.shortname or (self.icons and self.icons != " "):
            new_name += f":​{self.num}: "
            if self.shortname:
                new_name += self.shortname
            if self.icons:
                new_name += " " + self.icons

        return new_name


class Workspace(i3ipc.Con):
    name: str


class DyanmicWorkspaces:
    CHANGE_EVENTS: ClassVar[frozenset[str]] = frozenset({"new", "close", "move"})

    def __init__(self) -> None:
        self.ipc = i3ipc.Connection()

        def window_event_handler(_, e) -> None:
            if e.change in self.CHANGE_EVENTS:
                self.rename_workspaces()

        self.ipc.on("window", window_event_handler)
        self.rename_workspaces()
        self.ipc.main()

    @staticmethod
    def icon_for_window(window: Window) -> str:
        if window.ipc_data["shell"] == "xwayland":
            return XWAYLAND_ICON

        name = ""
        if window.app_id:
            name = "wine" if window.app_id.endswith(".exe") else window.app_id.lower()
        elif window.window_class:
            name = window.window_class.lower()

        return WINDOW_ICONS.get(name, DEFAULT_ICON)

    @staticmethod
    def parse_workspace_name(name: str) -> WorkspaceNameParts:
        match = re.match(
            r"(?P<num>[0-9]+):?(?P<shortname>\w+)? ?(?P<icons>.+)?",
            name,
        )
        if not match:
            raise
        return WorkspaceNameParts(**match.groupdict())

    @staticmethod
    def construct_workspace_name(parts: WorkspaceNameParts) -> str:
        new_name = str(parts.num)
        if parts.shortname or (parts.icons and parts.icons != " "):
            new_name += f":​{parts.num}: "
            if parts.shortname:
                new_name += parts.shortname
            if parts.icons:
                new_name += " " + parts.icons

        return new_name

    def get_workspaces(self) -> list[Workspace]:
        return self.ipc.get_tree().workspaces()  # type: ignore

    def rename_workspace(self, previous_name: str, new_name: str) -> None:
        self.ipc.command(f"rename workspace '{previous_name}' to '{new_name}'")

    def rename_workspaces(self) -> None:
        for workspace in self.get_workspaces():
            name_parts = self.parse_workspace_name(workspace.name)
            icons: set[str] = set()

            for w in workspace:
                window = Window(
                    app_id=w.app_id,
                    ipc_data=w.ipc_data,
                    window_class=w.window_class,
                )
                if window.app_id or window.window_class:
                    icon = self.icon_for_window(window)
                    icons.add(icon)

            name_parts.icons = "  ".join(icons) + " "
            new_name = self.construct_workspace_name(name_parts)
            self.rename_workspace(workspace.name, new_name)

    def __del__(self):
        for workspace in self.get_workspaces():
            name_parts = self.parse_workspace_name(workspace.name)
            name_parts.icons = None
            new_name = self.construct_workspace_name(name_parts)
            self.rename_workspace(workspace.name, new_name)
        self.ipc.main_quit()


if __name__ == "__main__":
    DyanmicWorkspaces()
