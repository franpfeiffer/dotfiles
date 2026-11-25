#!/usr/bin/env bash
# fresh install: ./install.sh   (on a freshly installed arch/omarchy)
set -euo pipefail
cd "$(dirname "$0")"

# ask for sudo once, keep it alive until the script ends (no prompts later)
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done &

# yay comes with omarchy; pacman only to bootstrap it if missing
if ! command -v yay >/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
fi
# repos + aur in one go; if a package is gone, retry one by one so the rest still install
Y=(yay --needed --noconfirm --sudoloop --answerclean None --answerdiff None --answeredit None --removemake)
"${Y[@]}" -Syu $(<packages/yay.txt) || for p in $(<packages/yay.txt); do "${Y[@]}" -S "$p" || echo "yay failed: $p"; done

# configs (backs up anything it overwrites)
rsync -a --backup --suffix=".pre-dotfiles" home/ "$HOME/"

# omarchy ships its own nvim (lazyvim): delete it and clone mine
[ -d ~/.config/nvim/.git ] || { rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; git clone https://github.com/franpfeiffer/nvim.git ~/.config/nvim; } || echo "nvim failed, check it"

# brew only for my apps (f4, t2) until they're on the aur
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] || NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || echo "brew install failed, check it"
/home/linuxbrew/.linuxbrew/bin/brew install $(<packages/brew.txt) || echo "brew failed, check it"

# node via mise, then global npm packages
mise install || echo "mise failed, check it"
mise exec -- npm i -g $(<packages/npm.txt) || echo "npm failed, check it"

# claude code
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash || echo "claude failed, check it"

./debloat.sh

systemctl --user daemon-reload
systemctl --user enable elephant.service swayosd-server.service omarchy-battery-monitor.timer 2>/dev/null || true

[ -f ~/.secrets ] || { touch ~/.secrets; chmod 600 ~/.secrets; echo ">> fill in ~/.secrets with your api keys"; }
[ "$SHELL" = "$(command -v zsh)" ] || sudo chsh -s "$(command -v zsh)" "$USER"
echo "done. log out and back in."
