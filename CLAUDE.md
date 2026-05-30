# CLAUDE.md — Reglas del repo `arch-deox`

Entorno Arch Linux riceado y **reproducible** (gestionado con **chezmoi**), estética tipo
eDEX-UI. Máquina: portátil Medion (Intel Iris Xe). Usuario `deox`, nuevo en Arch.

## Cómo trabajar aquí (IMPORTANTE)
1. **Planifica primero.** No toques el sistema hasta que el usuario apruebe el plan.
2. **Dotfiles en el repo PRIMERO.** Edita en `home/dot_config/...`, luego `chezmoi diff`,
   muestra el diff, **pide confirmación** y solo entonces `chezmoi apply`.
3. **Pide confirmación antes de**: `sudo`, `pacman -S`, `paru -S`, `rm`, `git push`,
   `curl … | sh` (o `strap.sh`), y antes de instalar algo pesado (Electron, eDEX-UI, ISO).
4. **Nunca** hagas commit de secretos. Si hicieran falta, usa **age + chezmoi**.
5. **Base Arch PURA.** BlackArch entra **solo como capa** y **por categorías**, nunca el
   meta-grupo completo.
6. **Family-friendly:** el usuario es nuevo en Arch. Explica lo que haces, en español.

## Estructura
- `home/` → raíz chezmoi (`.chezmoiroot`). Mapea a `$HOME`. Aquí van los dotfiles.
- `packages/` → `pkglist-native.txt` (pacman) y `pkglist-aur.txt` (AUR). No gestionado por chezmoi.
- `pentest/` → ficheros de menú XDG estilo Kali para categorías BlackArch.
- `docs/` → documentación, incl. `GUIA-ARCH-PARA-NOVATOS.md`.

## Estética (decidida)
- Escritorio (Hyprland / Waybar / Rofi / Mako): **Catppuccin Mocha**.
- Terminal del día a día (kitty): **neón Tron** (cian/verde sobre negro).
- Panel sci-fi tipo eDEX: comando **`deoxhud`** (NO `edex`, por respeto al autor de eDEX-UI),
  modo aparte. Levanta un layout tmux con btop, fastfetch, cava, tty-clock y cmatrix.

## Capas del entorno (independientes, no se pisan)
1. **Hyprland** = base / compositor.
2. **deoxhud** = terminal sci-fi (visual y funcional), invocada a demanda.
3. **Cate** = extra opcional para vibecoding con IA (AppImage, fuera de dotfiles).

## Reproducir en otra máquina
`chezmoi init --apply <usuario-github>` regenera todos los dotfiles. Luego instalar paquetes
desde `packages/`. Ver `README.md`.
