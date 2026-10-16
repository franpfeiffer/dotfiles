#!/usr/bin/env bash
# Saca de Omarchy lo que no uso. Lista de paquetes en packages/debloat.txt
set -euo pipefail
cd "$(dirname "$0")"

# paquetes (de a uno: si uno falla no frena al resto)
while read -r p; do
  [ -n "$p" ] && pacman -Qq "$p" &>/dev/null && { sudo pacman -Rns --noconfirm "$p" || echo "no pude sacar $p"; }
done < packages/debloat.txt

# atajos de hypr de apps/webapps borradas
sed -i -E '/hey\.com|grok\.com|x\.com|messages\.google|photos\.google|chatgpt\.com|youtube\.com|typora|signal|obsidian|1password|cliamp/d' ~/.config/hypr/bindings.conf

# lanzadores de webapps (menos WhatsApp)
for f in ~/.local/share/applications/*.desktop; do
  grep -q 'omarchy-launch-webapp\|omarchy-webapp-handler' "$f" && [[ "$f" != *whatsapp* ]] && rm -f "$f"
done

# ponytail: las configs de las apps (~/.config/Signal, etc) quedan, borrarlas a mano si querés
hyprctl reload &>/dev/null || true
echo "debloat listo"
