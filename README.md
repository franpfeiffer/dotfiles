# dotfiles

## before reinstalling

```bash
~/dotfiles/save.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
tar czf - -C ~ .ssh/id_ed25519 .ssh/id_ed25519.pub .config/t2stock/config.json | gpg -c -o ~/secrets-backup.tar.gz.gpg
```

save `secrets-backup.tar.gz.gpg` somewhere safe (usb, drive). not in the repo.

## install

```bash
gh auth login
git clone https://github.com/franpfeiffer/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
gpg -d secrets-backup.tar.gz.gpg | tar xzf - -C ~ && chmod 600 ~/.ssh/id_ed25519
```

log out and back in.
