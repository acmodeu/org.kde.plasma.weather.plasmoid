#!/usr/bin/env bash

# Installation script for Open-Meteo Weather Plasma 6 Plasmoid

PLASMOID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${PLASMOID_DIR}/package"
PLUGIN_ID="org.kde.plasma.weather.openmeteo"

echo "Installing Open-Meteo Weather Plasmoid (ID: ${PLUGIN_ID})..."

# Clear Plasma shell QML cache to ensure new version is loaded
rm -rf "${HOME}/.cache/plasmashell/qmlcache" 2>/dev/null
rm -rf "${HOME}/.cache/plasma*" 2>/dev/null

WAS_RUNNING=0
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    WAS_RUNNING=1
    echo "Stopping plasmashell to update configuration..."
    systemctl --user stop plasma-plasmashell.service 2>/dev/null
elif pgrep -x "plasmashell" >/dev/null 2>&1; then
    WAS_RUNNING=2
    echo "Stopping plasmashell to update configuration..."
    kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null
    sleep 1
fi

# Clean up any cached popup dimensions from previous manual resizes
if command -v kwriteconfig6 >/dev/null 2>&1; then
    CONFIG_FILE="${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
    if [ -f "${CONFIG_FILE}" ]; then
        grep -B 2 "plugin=${PLUGIN_ID}" "${CONFIG_FILE}" 2>/dev/null | grep "^\[Containments\]" | tr -d '[]' | while read -r group_path; do
            IFS='/' read -ra groups <<< "$(echo "$group_path" | sed 's/\]\[/\//g')"
            args=("--file" "plasma-org.kde.plasma.desktop-appletsrc")
            for g in "${groups[@]}"; do
                args+=("--group" "$g")
            done
            args+=("--group" "Configuration")
            kwriteconfig6 "${args[@]}" --key popupWidth --delete 2>/dev/null || true
            kwriteconfig6 "${args[@]}" --key popupHeight --delete 2>/dev/null || true
        done
    fi
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
    if [ -d "${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}" ]; then
        kpackagetool6 --type Plasma/Applet -u "${PACKAGE_DIR}" 2>/dev/null || \
        kpackagetool6 --type Plasma/Applet -i "${PACKAGE_DIR}"
    else
        kpackagetool6 --type Plasma/Applet -i "${PACKAGE_DIR}"
    fi
    echo "Done! Plasmoid package updated."
else
    echo "Error: kpackagetool6 not found. Make sure KDE Plasma 6 development tools are installed."
    exit 1
fi

command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 2>/dev/null

if [ $WAS_RUNNING -eq 1 ]; then
    echo "Starting plasmashell via systemd..."
    systemctl --user start plasma-plasmashell.service
elif [ $WAS_RUNNING -eq 2 ]; then
    echo "Starting plasmashell..."
    plasmashell >/dev/null 2>&1 &
    disown
fi

echo "Installation complete!"
