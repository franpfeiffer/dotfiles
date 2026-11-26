#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

DOTS=(
  .zshrc .tmux.conf .XCompose .gitignore_global
  .local/bin/tmux-sessionizer .local/bin/ghui
  .config/fcitx5 .config/ghostty .config/tmux .config/starship.toml
  .config/git .config/btop/btop.conf .config/fastfetch .config/lazygit .config/lazydocker
  .config/mise .config/user-dirs.dirs .config/omarchy/backgrounds
  .claude/settings.json .claude/CLAUDE.md .claude/skills .claude/projects/-home-fran/memory .agents .codex/config.toml
)

rm -rf home && mkdir home
for d in "${DOTS[@]}"; do
  [ -e "$HOME/$d" ] || { echo "skip $d (not found)"; continue; }
  mkdir -p "home/$(dirname "$d")"
  rsync -a --exclude='.git' --exclude='*.bak*' --exclude='node_modules' "$HOME/$d" "home/$(dirname "$d")/"
done
find home -type l -lname '/*' -print -delete | sed 's/^/dropped absolute symlink: /'

if [ -f ~/.config/hypr/hyprland.lua ]; then
  for f in hyprland bindings input looknfeel; do cp ~/.config/hypr/$f.lua hypr/; done
fi

python3 - <<'PY2'
import json
f = "home/.claude/settings.json"
d = json.load(open(f))
d.pop("autoMode", None)
d["statusLine"] = {"type": "command", "command": "bash -c 'bash \"$(ls ~/.claude/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh | tail -1)\"'"}
json.dump(d, open(f, "w"), indent=2)
PY2
awk '/^\[/{skip=($0 ~ /^\[(projects\.|mcp_servers\.Neon)/)} !skip' home/.codex/config.toml > home/.codex/c && mv home/.codex/c home/.codex/config.toml
sed -i -E '/^export [A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=/d' home/.zshrc
sed -i "s#$HOME#\$HOME#g" home/.zshrc
sed -i "s#$HOME#~#g" home/.config/git/config
grep -q 'mise activate' home/.zshrc || printf '\neval "$(mise activate zsh)"\n' >> home/.zshrc
grep -q 'source ~/.secrets' home/.zshrc || printf '\n[ -f ~/.secrets ] && source ~/.secrets\n' >> home/.zshrc

if [ -f ~/.dotfiles-private ]; then
  while read -r t; do
    [ -n "$t" ] || continue
    sed -i "s# ~/work/$t[^ ]*##g" home/.local/bin/tmux-sessionizer
    grep -rliI -- "$t" home | xargs -r sed -i "/$t/Id"
  done < ~/.dotfiles-private
fi

O=${OMARCHY_PATH:-/usr/share/omarchy}
[ -d "$O/install" ] || O=~/.local/share/omarchy
{ pacman -Qqe; echo go; echo love; } | sort -u | grep -vxFf <(cat packages/debloat.txt packages/skip.txt "$O"/install/omarchy-*.packages 2>/dev/null | grep -v '^#') | grep -v -- '-debug$' | grep -v '^omarchy' > packages/yay.txt
command -v brew >/dev/null && { brew leaves | grep '^franpfeiffer/' > packages/brew.txt || true; }
npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | sed 's#.*/node_modules/##' | grep -vxE 'npm|corepack|neon|pnpm' | grep -vxFf packages/skip.txt > packages/npm.txt || true

echo "done. check: git diff --stat"
