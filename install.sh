#!/usr/bin/env bash
# Instalación fresca: ./install.sh   (sobre Arch/Omarchy recién instalado)
set -euo pipefail
cd "$(dirname "$0")"

sudo pacman -Syu --needed --noconfirm - < packages/pacman.txt

if ! command -v yay >/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm - < packages/aur.txt || echo "algunos AUR fallaron, revisar"

# configs (backup de lo que pise)
rsync -a --backup --suffix=".pre-dotfiles" home/ "$HOME/"

[ -d ~/.oh-my-zsh ] || RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
[ -d ~/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/tpm
[ -d ~/.config/nvim ] || git clone https://github.com/franpfeiffer/nvim.git ~/.config/nvim
[ -d ~/.emacs.d ] || git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d

if command -v cursor >/dev/null && [ -f packages/cursor-extensions.txt ]; then
  xargs -n1 cursor --install-extension < packages/cursor-extensions.txt || true
fi

./debloat.sh

systemctl --user daemon-reload
systemctl --user enable elephant.service swayosd-server.service omarchy-battery-monitor.timer 2>/dev/null || true

[ -f ~/.secrets ] || { touch ~/.secrets; chmod 600 ~/.secrets; echo ">> completá ~/.secrets con tus API keys"; }
[ "$SHELL" = "$(command -v zsh)" ] || chsh -s "$(command -v zsh)"
echo "listo. reiniciá sesión."
