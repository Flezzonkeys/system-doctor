#!/bin/bash
# Installs System Doctor. Run from the project folder with: sudo bash install.sh
set -euo pipefail
SRC=$(cd "$(dirname "$0")" && pwd)
PREFIX=/usr/local

[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo: sudo bash install.sh"; exit 1; }
command -v pacman >/dev/null || { echo "System Doctor needs an Arch-based system (pacman)."; exit 1; }

# Tool -> Arch package that provides it
declare -A NEED=(
    [python3]=python [smartctl]=smartmontools [sensors]=lm_sensors [checkupdates]=pacman-contrib
    [dmidecode]=dmidecode [notify-send]=libnotify [lspci]=pciutils
)
missing=()
for tool in "${!NEED[@]}"; do
    command -v "$tool" >/dev/null || missing+=("${NEED[$tool]}")
done
python3 -c 'import PyQt6.QtWidgets' 2>/dev/null || missing+=(python-pyqt6)
if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing packages: ${missing[*]}"
    read -rp "Install them now with pacman? [Y/n] " answer
    case ${answer:-y} in
        [Yy]*) pacman -S --needed "${missing[@]}" ;;
        *) echo "Aborted. Install them with: sudo pacman -S --needed ${missing[*]}"; exit 1 ;;
    esac
fi

install -Dm755 "$SRC/src/system-doctor"         "$PREFIX/bin/system-doctor"
install -Dm755 "$SRC/src/system-doctor-gui"     "$PREFIX/bin/system-doctor-gui"
install -Dm755 "$SRC/src/doctor"                "$PREFIX/bin/doctor"
install -Dm644 "$SRC/data/system-doctor.service" /etc/systemd/system/system-doctor.service
install -Dm644 "$SRC/data/system-doctor.timer"   /etc/systemd/system/system-doctor.timer
install -Dm644 "$SRC/data/50-system-doctor.rules" /etc/polkit-1/rules.d/50-system-doctor.rules
install -Dm644 "$SRC/data/system-doctor.desktop" "$PREFIX/share/applications/system-doctor.desktop"
install -Dm644 "$SRC/data/system-doctor.svg"     "$PREFIX/share/icons/hicolor/scalable/apps/system-doctor.svg"
gtk-update-icon-cache -q -t "$PREFIX/share/icons/hicolor" 2>/dev/null || true

systemctl daemon-reload
systemctl enable --now system-doctor.timer

echo "Running the first check..."
systemctl start system-doctor.service
echo
echo "Done. Open \"System Doctor\" from the app menu or type: doctor"
