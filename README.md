# arch-deox

Dotfiles y configuración reproducible de mi Arch Linux riceado con estética **eDEX-UI**
(sci-fi / consola hacker), gestionado con [chezmoi](https://chezmoi.io).

- **Compositor:** Hyprland (Wayland)
- **Estética escritorio:** Catppuccin Mocha · **terminal:** neón Tron
- **Panel sci-fi:** comando `deoxhud` (layout tmux con monitores)
- **Hardware de referencia:** portátil Medion, Intel Iris Xe

## Estructura

| Carpeta | Contenido |
|---|---|
| `home/` | Dotfiles (raíz chezmoi → `$HOME`): Hyprland, Waybar, Rofi, Mako, kitty, tmux, starship, fastfetch, cava, y el script `deoxhud`. |
| `packages/` | Listas por origen: `pkglist-native.txt` (repos oficiales), `pkglist-blackarch.txt` (repo BlackArch) y `pkglist-aur.txt` (AUR). Se regeneran con `./update-lists.sh`. |
| `pentest/` | Menús XDG estilo Kali para las categorías de BlackArch. |
| `docs/` | Documentación, incl. la **guía de Arch para novatos**. |

## Reinstalar desde cero (resumen)

1. Instala Arch base (archinstall) con red (NetworkManager) y `git`.
2. Dotfiles:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <usuario-github>
   ```
3. Paquetes oficiales (solo repos de Arch; lo de BlackArch y AUR va en sus propias listas):
   ```bash
   sudo pacman -S --needed - < packages/pkglist-native.txt
   ```
4. AUR — primero instala el helper `paru` (no puede instalarse a sí mismo, por eso no está
   en la lista), luego el resto:
   ```bash
   sudo pacman -S --needed git base-devel
   git clone https://aur.archlinux.org/paru.git /tmp/paru && (cd /tmp/paru && makepkg -si)
   paru -S --needed - < packages/pkglist-aur.txt
   ```
5. (Opcional) BlackArch por categorías — habilita el repo con `strap.sh` (ver `pentest/` y
   la guía) y luego instala su lista:
   ```bash
   sudo pacman -S --needed - < packages/pkglist-blackarch.txt
   ```

> Tras instalar/quitar paquetes, regenera las listas: `packages/update-lists.sh` (y commitea).

> ¿Nuevo en Arch? Lee **[docs/GUIA-ARCH-PARA-NOVATOS.md](docs/GUIA-ARCH-PARA-NOVATOS.md)**.

## Reglas del repo
Ver [CLAUDE.md](CLAUDE.md). Resumen: dotfiles primero → `chezmoi diff` → aplicar; confirmar
antes de instalar; base Arch pura; BlackArch solo como capa; sin secretos en commits.
