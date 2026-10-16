# dotfiles

## before reinstalling

```bash
~/dotfiles/save.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

back up `~/.secrets` separately (it's not in the repo).

## install

```bash
gh auth login
git clone https://github.com/franpfeiffer/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

copy `~/.secrets` back and log out/in.
