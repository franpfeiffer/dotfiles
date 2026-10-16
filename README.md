# dotfiles

## Before reinstalling

```bash
~/dotfiles/save.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

Back up `~/.secrets` separately (it's not in the repo).

## Install

```bash
gh auth login
git clone https://github.com/franpfeiffer/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Copy `~/.secrets` back and log out/in.
