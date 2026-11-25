#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

DOTS=(
  .zshrc .tmux.conf .XCompose .gitignore_global
  .local/bin/tmux-sessionizer .local/bin/ghui
  .config/hypr .config/waybar .config/walker .config/elephant .config/mako
  .config/swayosd .config/uwsm .config/omarchy .config/environment.d
  .config/systemd/user .config/fontconfig .config/fcitx5
  .config/ghostty .config/tmux .config/starship.toml
  .config/git .config/btop .config/fastfetch .config/lazygit .config/lazydocker
  .config/mise .config/mimeapps.list .config/user-dirs.dirs
  .config/xdg-terminals.list .config/brave-flags.conf .config/chromium-flags.conf
)

rm -rf home && mkdir home
for d in "${DOTS[@]}"; do
  [ -e "$HOME/$d" ] || { echo "skip $d (not found)"; continue; }
  mkdir -p "home/$(dirname "$d")"
  rsync -a --exclude='.git' --exclude='*.bak*' --exclude='node_modules' "$HOME/$d" "home/$(dirname "$d")/"
done

sed -i -E '/^export [A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=/d' home/.zshrc
grep -q 'mise activate' home/.zshrc || printf '\neval "$(mise activate zsh)"\n' >> home/.zshrc
grep -q 'source ~/.secrets' home/.zshrc || printf '\n[ -f ~/.secrets ] && source ~/.secrets\n' >> home/.zshrc

if [ -f ~/.dotfiles-private ]; then
  while read -r t; do
    [ -n "$t" ] || continue
    sed -i "s# ~/work/$t[^ ]*##g" home/.local/bin/tmux-sessionizer
    grep -rliI -- "$t" home | xargs -r sed -i "/$t/Id"
  done < ~/.dotfiles-private
fi

{ pacman -Qqe; echo go; echo love; } | sort -u | grep -vxFf packages/debloat.txt | grep -v -- '-debug$' | grep -vx omarchy-walker > packages/yay.txt
command -v brew >/dev/null && { brew leaves | grep '^franpfeiffer/' > packages/brew.txt || true; }
npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | sed 's#.*/node_modules/##' | grep -vxE 'npm|corepack|neon' > packages/npm.txt || true

echo "done. check: git diff --stat"
