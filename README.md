# dotfiles

## before reinstalling

```bash
~/dotfiles/save.sh && cd ~/dotfiles && git add -A && git commit -m "update"; git push
```

copy to a usb (not in the repo): `~/.secrets`, `~/.ssh/reportar-deploy*`

## install

on a fresh omarchy:

```bash
gh auth login -p ssh -w && GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" gh repo clone franpfeiffer/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

- gh asks to generate an ssh key: yes, empty passphrase, name it after the machine. it uploads it to github.
- sudo password once, then it runs alone.
- log out and back in.
