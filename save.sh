#!/usr/bin/env bash
# Copia configs de esta máquina al repo. Correr cuando cambies algo, después commit.
set -euo pipefail
cd "$(dirname "$0")"

# ponytail: lista explícita, agregar acá lo que quieras versionar
DOTS=(
  .zshrc .tmux.conf .XCompose .gitignore_global
  .local/bin/tmux-sessionizer
  .config/hypr .config/waybar .config/walker .config/elephant .config/mako
  .config/swayosd .config/uwsm .config/omarchy .config/environment.d
  .config/systemd/user .config/fontconfig .config/fcitx5
  .config/ghostty .config/kitty .config/alacritty .config/tmux .config/starship.toml
  .config/git .config/btop .config/fastfetch .config/lazygit .config/lazydocker
  .config/mise .config/zed .config/doom .config/mimeapps.list .config/user-dirs.dirs
  .config/xdg-terminals.list .config/brave-flags.conf .config/chromium-flags.conf
  .config/opencode/opencode.json .config/opencode/tui.json
  .config/Cursor/User/settings.json .config/Cursor/User/keybindings.json .config/Cursor/User/snippets
)

rm -rf home && mkdir home
for d in "${DOTS[@]}"; do
  [ -e "$HOME/$d" ] || { echo "skip $d (no existe)"; continue; }
  mkdir -p "home/$(dirname "$d")"
  rsync -a --exclude='.git' --exclude='*.bak*' --exclude='node_modules' "$HOME/$d" "home/$(dirname "$d")/"
done

# secretos fuera del repo: van en ~/.secrets (no versionado)
sed -i -E '/^export [A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=/d' home/.zshrc
# MCP de Neon = laburo, afuera
python3 - <<'PY'
import json
for f, k in [("home/.config/opencode/opencode.json", "mcp"), ("home/.config/zed/settings.json", "context_servers")]:
    try: d = json.load(open(f))
    except (OSError, ValueError): continue
    d.get(k, {}).pop("Neon", None)
    if not d.get(k): d.pop(k, None)
    json.dump(d, open(f, "w"), indent=2)
PY
grep -q 'source ~/.secrets' home/.zshrc || printf '\n[ -f ~/.secrets ] && source ~/.secrets\n' >> home/.zshrc

# términos privados (laburo, etc) en ~/.dotfiles-private, uno por línea, fuera del repo
if [ -f ~/.dotfiles-private ]; then
  while read -r t; do
    [ -n "$t" ] || continue
    sed -i "s# ~/work/$t[^ ]*##g" home/.local/bin/tmux-sessionizer
    grep -rliI -- "$t" home | xargs -r sed -i "/$t/Id"
  done < ~/.dotfiles-private
fi

pacman -Qqen > packages/pacman.txt
pacman -Qqem > packages/aur.txt
command -v cursor >/dev/null && cursor --list-extensions | grep -vi neon | grep -viFf ~/.dotfiles-private > packages/cursor-extensions.txt 2>/dev/null || true

echo "listo. revisá: git diff --stat"
