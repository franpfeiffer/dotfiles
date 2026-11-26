#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

while read -r p; do
  [ -n "$p" ] && pacman -Qq "$p" &>/dev/null && { sudo pacman -Rns --noconfirm "$p" || echo "remove $p failed, check it"; }
done < packages/debloat.txt

for f in ~/.local/share/applications/*.desktop; do
  grep -q 'omarchy-launch-webapp\|omarchy-webapp-handler' "$f" && [[ "$f" != *whatsapp* ]] && rm -f "$f"
done

hyprctl reload &>/dev/null || true
echo "debloat done"
