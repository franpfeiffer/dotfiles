#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

while read -r p; do
  [ -n "$p" ] && pacman -Qq "$p" &>/dev/null && { sudo pacman -Rns --noconfirm "$p" || echo "remove $p failed, check it"; }
done < packages/debloat.txt

sed -i -E '/hey\.com|grok\.com|x\.com|messages\.google|photos\.google|chatgpt\.com|youtube\.com|typora|signal|obsidian|1password|cliamp/d' ~/.config/hypr/bindings.conf

for f in ~/.local/share/applications/*.desktop; do
  grep -q 'omarchy-launch-webapp\|omarchy-webapp-handler' "$f" && [[ "$f" != *whatsapp* ]] && rm -f "$f"
done

hyprctl reload &>/dev/null || true
echo "debloat done"
