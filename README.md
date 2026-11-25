# dotfiles

## before reinstalling

```bash
~/dotfiles/save.sh && cd ~/dotfiles && git add -A && git commit -m "update"; git push
```

## install

on a fresh omarchy:

```bash
gh auth login -p ssh -w && GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" gh repo clone franpfeiffer/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

- gh: enter on everything (it generates a new ssh key and uploads it), authorize in the browser.
- sudo password once, then it runs alone.
- it logs out by itself at the end (if something failed it shows it and waits for enter). log back in, fill `~/.secrets` with api keys when you need them.
