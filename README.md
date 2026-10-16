# dotfiles

Mi setup de Arch + Omarchy: paquetes, configs y debloat. Un solo script lo instala todo.

## Primera vez: subir a GitHub

Con `gh` logueado:

```bash
cd ~/dotfiles && gh repo create dotfiles --private --source . --push
```

Dejarlo **privado**. Las configs no tienen claves, pero muestran rutas y la estructura de la máquina.

## Antes de formatear

1. Pasar las API keys de `~/.zshrc` a `~/.secrets` (ver [Secretos](#secretos)).
2. Guardar `~/.secrets` en un lugar seguro (gestor de contraseñas o pendrive cifrado). No se sube a GitHub, así que si no lo guardás, en la máquina nueva no está.
3. Correr `~/dotfiles/save.sh` y hacer push, para que el repo tenga lo último.

## Instalar en una máquina nueva

1. Instalar Omarchy normalmente desde el pendrive.
2. Abrir una terminal y correr:

```bash
gh auth login
git clone https://github.com/franpfeiffer/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

3. Completar `~/.secrets` con las API keys (ver abajo).
4. Cerrar sesión y volver a entrar.

`install.sh` hace todo, en este orden:

- instala los paquetes oficiales (`packages/pacman.txt`) y los de AUR (`packages/aur.txt`)
- copia las configs de `home/` a `~`; lo que pisa queda como `*.pre-dotfiles`
- instala oh-my-zsh, tpm (plugins de tmux), mi nvim y doom emacs
- instala las extensiones de Cursor
- corre `debloat.sh`, que saca lo que Omarchy trae y no uso
- activa los servicios de usuario y pone zsh como shell

Se puede correr varias veces sin romper nada.

`gh auth login` hace falta porque el repo es privado.

No está probado todavía en una máquina limpia: la primera instalación real es la prueba. Si algo falla, el script frena y muestra dónde.

## Secretos

Las API keys **no** están en el repo. Van en `~/.secrets`, que `.zshrc` carga solo:

```bash
export NVIDIA_API_KEY=...
export LIGHTNING_API_KEY=...
```

## Guardar cambios de esta máquina

Cuando cambies una config o instales algo:

```bash
~/dotfiles/save.sh
cd ~/dotfiles && git add -A && git commit -m "update" && git push
```

- Para versionar algo nuevo, agregalo a la lista `DOTS` en `save.sh`.
- Para que algo nunca entre al repo (cosas de laburo, etc.), escribí el término en `~/.dotfiles-private`, uno por línea. Ese archivo no se sube.

## Debloat

`debloat.sh` saca los paquetes de `packages/debloat.txt`, las webapps de Omarchy (menos WhatsApp) y sus atajos de hypr. Las configs de esas apps quedan en el disco. Para sacar algo más, agregalo a `debloat.txt`. Para conservar algo, borralo de ahí.

## Estructura

```
install.sh     instala todo (único archivo a ejecutar)
save.sh        copia las configs de esta máquina al repo
debloat.sh     saca lo que no uso de Omarchy
packages/      listas de paquetes y extensiones
home/          configs, con la misma estructura que ~
```
