#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec > >(tee ~/dotfiles-install.log) 2>&1

sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done &

if ! command -v yay >/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
fi
for i in $(seq 150); do [ -e /var/lib/pacman/db.lck ] || break; sleep 2; done
command -v omarchy-update >/dev/null && { omarchy-update -y || echo "omarchy update failed, check it"; }
Y=(yay --needed --noconfirm --sudoloop --answerclean None --answerdiff None --answeredit None --removemake)
P=$(pacman -T $(<packages/yay.txt) || true)
[ -z "$P" ] || "${Y[@]}" -S $P || for p in $P; do "${Y[@]}" -S "$p" || echo "yay failed: $p"; done

mkdir -p ~/work ~/personal
mkdir -p ~/.local/state/omarchy/{toggles,indicators}
touch ~/.local/state/omarchy/toggles/{screensaver-off,suspend-off} ~/.local/state/omarchy/indicators/stay-awake
rsync -a --backup --suffix=".pre-dotfiles" home/ "$HOME/"
M=~/.claude/projects/$(tr / - <<<"$HOME")
[ -d "$M" ] || mv ~/.claude/projects/-home-fran "$M" 2>/dev/null || true
if [ -f ~/.config/hypr/hyprland.lua ]; then
  for f in hypr/*.lua; do cp -b --suffix=.pre-dotfiles "$f" ~/.config/hypr/; done
else
  echo "hypr config not lua (old omarchy?), skipped, check it"
fi

[ -d ~/.config/nvim/.git ] || { rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; git clone https://github.com/franpfeiffer/nvim.git ~/.config/nvim; } || echo "nvim failed, check it"

[ -x /home/linuxbrew/.linuxbrew/bin/brew ] || NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || echo "brew install failed, check it"
/home/linuxbrew/.linuxbrew/bin/brew install $(<packages/brew.txt) || echo "brew failed, check it"

mise install || echo "mise failed, check it"
mise exec -- npm i -g $(<packages/npm.txt) || echo "npm failed, check it"

command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash || echo "claude failed, check it"

./debloat.sh || echo "debloat failed, check it"

[ -f ~/.secrets ] || { touch ~/.secrets; chmod 600 ~/.secrets; echo ">> fill in ~/.secrets with your api keys"; }
[ "$SHELL" = "$(command -v zsh)" ] || sudo chsh -s "$(command -v zsh)" "$USER"
F=$(grep -E '^yay failed: | failed, check it$' ~/dotfiles-install.log || true)
if [ -n "$F" ]; then
  echo "$F"; read -rp "done with failures (log: ~/dotfiles-install.log). enter to reboot " </dev/tty
else
  echo "done. rebooting in 10s (ctrl+c to stay)"; sleep 10
fi
systemctl reboot
