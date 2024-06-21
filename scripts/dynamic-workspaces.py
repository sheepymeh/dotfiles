#!/usr/bin/python

# Adapted from https://github.com/swaywm/sway/blob/master/contrib/autoname-workspaces.py

import i3ipc
import re
import signal
import sys

WINDOW_ICONS = {
    "firefox": "",
    "alacritty": "",
    "codium-url-handler": "",
    "geforce now": "",
    "chromium": "",
    "signal-desktop": "",
    "pavucontrol": "",
    "virt-manager": "",
    "com.nextcloud.desktopclient.nextcloud": "",
    "desktopclient.owncloud.com.owncloud": "",
    "nwg-displays": "",
    "blueman-manager": "",
    "libreoffice": "",
    "libreoffice-writer": "",
    "libreoffice-impress": "",
    "libreoffice-calc": "",
    "libreoffice-math": "",
    "libreoffice-draw": "",
    "libreoffice-base": "",
    "imv": "",
    "thunar": "",
    "thunderbird": "",
}

DEFAULT_ICON = ""

def icon_for_window(window):
    name = None
    if window.app_id is not None and len(window.app_id) > 0:
        name = window.app_id.lower()
    elif window.window_class is not None and len(window.window_class) > 0:
        name = window.window_class.lower()
    return WINDOW_ICONS.get(name, DEFAULT_ICON)

def ipc_rename_workspace(previous_name, new_name):
    ipc.command(f"rename workspace '{previous_name}' to '{new_name}'")

def rename_workspaces(ipc):
    for workspace in ipc.get_tree().workspaces():
        name_parts = parse_workspace_name(workspace.name)
        icons = []
        for w in workspace:
            if w.app_id is not None or w.window_class is not None:
                icon = icon_for_window(w)
                if icon in icons:
                    continue
                icons.append(icon)
        name_parts["icons"] = "  ".join(icons) + " "
        new_name = construct_workspace_name(name_parts)
        ipc_rename_workspace(workspace.name, new_name)

def undo_window_renaming(ipc):
    for workspace in ipc.get_tree().workspaces():
        name_parts = parse_workspace_name(workspace.name)
        new_name = name_parts["num"]
        ipc_rename_workspace(workspace.name, new_name)
    ipc.main_quit()
    sys.exit(0)

def parse_workspace_name(name):
    return re.match(
        "(?P<num>[0-9]+):?(?P<shortname>\w+)? ?(?P<icons>.+)?", name
    ).groupdict()

def construct_workspace_name(parts):
    new_name = str(parts["num"])
    if parts["shortname"] or (parts["icons"] and parts["icons"] != " "):
        new_name += f":​{parts['num']}: "
        if parts["shortname"]:
            new_name += parts["shortname"]
        if parts["icons"]:
            new_name += " " + parts["icons"]
    else:
        new_name += ""

    return new_name

if __name__ == "__main__":
    ipc = i3ipc.Connection()

    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda signal, frame: undo_window_renaming(ipc))

    def window_event_handler(ipc, e):
        if e.change in ["new", "close", "move"]:
            rename_workspaces(ipc)

    ipc.on("window", window_event_handler)

    rename_workspaces(ipc)

    ipc.main()
