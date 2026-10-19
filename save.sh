#!/usr/bin/env bash
# copy this machine's configs into the repo. run after changing something, then commit.
set -euo pipefail
cd "$(dirname "$0")"

# ponytail: explicit list, add here whatever you want versioned
DOTS=(
  .zshrc .tmux.conf .XCompose .gitignore_global
  .local/bin/tmux-sessionizer .local/bin/opencode-99 .local/bin/ghui
  .config/hypr .config/waybar .config/walker .config/elephant .config/mako
  .config/swayosd .config/uwsm .config/omarchy .config/environment.d
  .config/systemd/user .config/fontconfig .config/fcitx5
  .config/ghostty .config/tmux .config/starship.toml
  .config/git .config/btop .config/fastfetch .config/lazygit .config/lazydocker
  .config/mise .config/doom .config/mimeapps.list .config/user-dirs.dirs
  .config/xdg-terminals.list .config/brave-flags.conf .config/chromium-flags.conf
  .config/opencode/opencode.json .config/opencode/tui.json
)

rm -rf home && mkdir home
for d in "${DOTS[@]}"; do
  [ -e "$HOME/$d" ] || { echo "skip $d (not found)"; continue; }
  mkdir -p "home/$(dirname "$d")"
  rsync -a --exclude='.git' --exclude='*.bak*' --exclude='node_modules' "$HOME/$d" "home/$(dirname "$d")/"
done

# secrets stay out of the repo: they live in ~/.secrets (not versioned)
sed -i -E '/^export [A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=/d' home/.zshrc
# neon mcp is work stuff, keep it out
python3 - <<'PY'
import json
for f, k in [("home/.config/opencode/opencode.json", "mcp"), ("home/.config/zed/settings.json", "context_servers")]:
    try: d = json.load(open(f))
    except (OSError, ValueError): continue
    d.get(k, {}).pop("Neon", None)
    if not d.get(k): d.pop(k, None)
    json.dump(d, open(f, "w"), indent=2)
PY
# node comes from mise on new machines (nvm lines stay guarded and harmless)
grep -q 'mise activate' home/.zshrc || printf '\neval "$(mise activate zsh)"\n' >> home/.zshrc
grep -q 'source ~/.secrets' home/.zshrc || printf '\n[ -f ~/.secrets ] && source ~/.secrets\n' >> home/.zshrc

# private terms (work, etc) in ~/.dotfiles-private, one per line, outside the repo
if [ -f ~/.dotfiles-private ]; then
  while read -r t; do
    [ -n "$t" ] || continue
    sed -i "s# ~/work/$t[^ ]*##g" home/.local/bin/tmux-sessionizer
    grep -rliI -- "$t" home | xargs -r sed -i "/$t/Id"
  done < ~/.dotfiles-private
fi

# nothing from debloat.txt goes into the lists
# go and love come from pacman (brew and snap on this machine)
{ pacman -Qqen; echo go; echo love; } | sort -u | grep -vxFf packages/debloat.txt > packages/pacman.txt
pacman -Qqem | grep -vxFf packages/debloat.txt | grep -v -- '-debug$' | grep -vx omarchy-walker > packages/aur.txt
# brew only for my own taps; everything else (go, etc) comes from pacman
command -v brew >/dev/null && brew leaves | grep '^franpfeiffer/' > packages/brew.txt
# global npm packages (minus npm itself and work stuff)
npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | sed 's#.*/node_modules/##' | grep -vxE 'npm|corepack|neon' > packages/npm.txt || true
command -v cursor >/dev/null && cursor --list-extensions | grep -vi neon | grep -viFf ~/.dotfiles-private > packages/cursor-extensions.txt 2>/dev/null || true

echo "done. check: git diff --stat"
