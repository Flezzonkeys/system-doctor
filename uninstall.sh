#!/bin/bash
# Removes System Doctor. Run from the project folder with: sudo bash uninstall.sh
set -euo pipefail
PREFIX=/usr/local

[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo: sudo bash uninstall.sh"; exit 1; }

systemctl disable --now system-doctor.timer 2>/dev/null || true
rm -f /etc/systemd/system/system-doctor.service /etc/systemd/system/system-doctor.timer \
      /etc/polkit-1/rules.d/50-system-doctor.rules \
      "$PREFIX/bin/system-doctor" "$PREFIX/bin/system-doctor-gui" "$PREFIX/bin/doctor" \
      "$PREFIX/share/applications/system-doctor.desktop" \
      "$PREFIX/share/icons/hicolor/scalable/apps/system-doctor.svg"
rm -rf /var/lib/system-doctor
systemctl daemon-reload
echo "System Doctor has been removed."
