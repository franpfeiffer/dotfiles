# dotfiles

## Subir

```bash
cd ~/dotfiles && gh repo create dotfiles --private --source . --push
```

## Antes de formatear

```bash
~/dotfiles/save.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

Guardar `~/.secrets` aparte (no está en el repo).

## Instalar

```bash
gh auth login
git clone https://github.com/franpfeiffer/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Copiar `~/.secrets` y reiniciar sesión.
