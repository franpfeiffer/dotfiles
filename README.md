# dotfiles

## before reinstalling

```bash
~/dotfiles/save.sh && cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

## install

```bash
gh auth login && gh repo clone franpfeiffer/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

log out and back in.
