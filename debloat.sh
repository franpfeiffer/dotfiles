#!/usr/bin/env bash
# Remove the Omarchy stuff I don't use. Package list in packages/debloat.txt
set -euo pipefail
cd "$(dirname "$0")"

# packages (one at a time: one failure doesn't stop the rest)
while read -r p; do
  [ -n "$p" ] && pacman -Qq "$p" &>/dev/null && { sudo pacman -Rns --noconfirm "$p" || echo "could not remove $p"; }
done < packages/debloat.txt

# hypr bindings for removed apps/webapps
sed -i -E '/hey\.com|grok\.com|x\.com|messages\.google|photos\.google|chatgpt\.com|youtube\.com|typora|signal|obsidian|1password|cliamp/d' ~/.config/hypr/bindings.conf

# webapp launchers (except WhatsApp)
for f in ~/.local/share/applications/*.desktop; do
  grep -q 'omarchy-launch-webapp\|omarchy-webapp-handler' "$f" && [[ "$f" != *whatsapp* ]] && rm -f "$f"
done

# ponytail: app configs (~/.config/Signal, etc) are kept, delete them by hand if you want
hyprctl reload &>/dev/null || true
echo "debloat done"
