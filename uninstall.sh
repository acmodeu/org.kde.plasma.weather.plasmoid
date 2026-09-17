#!/usr/bin/env bash

# Uninstallation script for Open-Meteo Weather Plasma 6 Plasmoid

PLUGIN_ID="org.kde.plasma.weather.openmeteo"

echo "Removing Open-Meteo Weather Plasmoid (ID: ${PLUGIN_ID})..."

WAS_RUNNING=0
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    WAS_RUNNING=1
    echo "Stopping plasmashell..."
    systemctl --user stop plasma-plasmashell.service 2>/dev/null
elif pgrep -x "plasmashell" >/dev/null 2>&1; then
    WAS_RUNNING=2
    echo "Stopping plasmashell..."
    kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null
    sleep 1
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet -r "${PLUGIN_ID}" 2>/dev/null
fi
rm -rf "${HOME}/.local/share/plasma/plasmoids/${PLUGIN_ID}" 2>/dev/null
rm -rf "${HOME}/.cache/plasmashell/qmlcache" 2>/dev/null
rm -rf "${HOME}/.cache/plasma*" 2>/dev/null

command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 2>/dev/null

if [ $WAS_RUNNING -eq 1 ]; then
    echo "Starting plasmashell via systemd..."
    systemctl --user start plasma-plasmashell.service
elif [ $WAS_RUNNING -eq 2 ]; then
    echo "Starting plasmashell..."
    plasmashell >/dev/null 2>&1 &
    disown
fi

echo "Uninstallation complete."
