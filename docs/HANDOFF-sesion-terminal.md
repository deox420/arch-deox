# HANDOFF — lo que hizo la "sesión terminal" (al 2026-06-01)

Contexto para la otra sesión (escritorio) / para retomar. Esta sesión llevó la **capa terminal
+ sistema** (Fases A, B, D, E, F, G, H). La **Fase C (escritorio)** es de la otra sesión.

## Reparto de ficheros (lanes)
- **Terminal (esta sesión):** `kitty/`, `tmux/`, `starship.toml`, `fastfetch/`, `cava/`,
  `deoxhud/`, `dot_local/bin/`, `dot_bashrc`, `packages/`, `pentest/`, `docs/`.
- **Escritorio (otra sesión):** `hypr/`, `waybar/`, `rofi/`, `mako/`, wallpaper.
- Regla: cada sesión commitea **solo sus ficheros** (`git add <rutas>`, nunca `-A`).

## Hecho por esta sesión

### A — Andamiaje (repo chezmoi)
- `chezmoi init` → fuente en `~/.local/share/chezmoi`, `git init` (rama `main`).
- `.chezmoiroot = home`. Estructura `home/dot_config`, `home/dot_local/bin`, `packages/`,
  `pentest/`, `docs/`. Creados `CLAUDE.md`, `README.md`, `.chezmoiignore`, `.gitignore`.

### B — Drivers Intel + AUR helper
- Instalados `vulkan-intel intel-media-driver libva-utils` (acel. vídeo Intel; `vainfo` OK).
- **paru** compilado **desde fuente** (el `paru-bin` precompilado fallaba por `libalpm.so.15`
  vs `.16` del sistema). Quedó `paru v2.1.0`.

### D — Panel `deoxhud` (dashboard sci-fi, NO se llama edex)
- Scripts: `~/.local/bin/deoxhud` y `~/.local/bin/deoxhud-globe` (en repo como
  `home/dot_local/bin/executable_*`).
- Layout: **globo-Tierra ASCII** girando (continentes verdes/mar azul, hecho en Python sin
  deps) + **reloj/fecha/calendario** (locale ES) arriba-izq; **btop** arriba-der; **terminal
  de trabajo** grande abajo (foco ahí).
- btop usa config compacta propia `~/.config/deoxhud/btop-panel.conf` (`shown_boxes="cpu mem"`).
- **Layout adaptable**: el script lee el tamaño real con `tput` y crea la sesión tmux a ese
  tamaño, dando a btop ≥18 filas → **sin "terminal too small"** (verificado de 36 a 52 filas).
- ⚠️ **Gotcha:** si la sesión tmux `deoxhud` ya existe, el script **reconecta** a ella (no la
  rehace). Tras cambiar el layout hay que cerrarla: dentro `Ctrl-a &`, o `tmux kill-session -t deoxhud`.
- Configs terminal: `kitty.conf` (paleta neón Tron + JetBrainsMono Nerd + opacidad 0.90),
  `starship.toml` (prompt neón), `tmux.conf` (prefijo `C-a`, tema neón), `fastfetch`, `cava`.

### E — Herramientas del sistema + listas
- Instalado: `neovim fzf ripgrep fd bat eza zoxide tree htop wget unzip man-db man-pages less
  bluez bluez-utils blueman pavucontrol network-manager-applet power-profiles-daemon`.
- Servicios activos: `bluetooth`, `power-profiles-daemon`.
- `.bashrc` integra eza/bat/zoxide/fzf y `EDITOR=nvim` (con guardas `command -v`).
- `packages/pkglist-native.txt` (base+escritorio+terminal, **sin** el kit pentest) y
  `pkglist-aur.txt` (= `tty-clock`; **paru se bootstrapea aparte**, ver README).

### F — Cate (extra, fuera de dotfiles)
- AppImage **v1.1.0** en `~/Applications/Cate-1.1.0.AppImage` (+`--no-sandbox`),
  lanzador `~/.local/share/applications/cate.desktop`. Necesita `fuse2` (instalado).

### G — BlackArch (capa, por categorías)
- Repo `[blackarch]` habilitado vía `strap.sh` **verificado por SHA1**
  (`00688950…525ed`, coincide con el oficial).
- **NO** se instaló el meta-grupo. Kit curado de **31 herramientas** (ver `pentest/kit-curado.txt`,
  instalable con `pentest/install-kit.sh`). Incluye nmap, sqlmap, metasploit, burpsuite,
  wireshark, hydra, john, hashcat, nuclei(+templates), etc. Docs y ética en `pentest/README.md`.

### H — Reproducibilidad + guía
- `docs/GUIA-ARCH-PARA-NOVATOS.md` (Arch vs Win/Ubuntu, pacman, WiFi, systemd, logs, fallos,
  estructura del repo, ciclo chezmoi, reinstalar de cero, glosario, ética pentest).
- `README.md` con pasos de reinstalación (incl. bootstrap de paru).

## Verificación (2026-06-01): SIN errores
- `chezmoi diff` de la capa terminal: vacío. Configs sin errores de parseo.
- `systemctl --failed` (sistema y usuario): ninguno. `hyprctl configerrors`: vacío.

## Gotchas técnicos útiles
- `sudo` lo ejecuta el USUARIO en su terminal (esta sesión no tiene tty para la contraseña).
- `chezmoi apply` puede pedir TTY si un fichero se editó a mano → usar `chezmoi apply --force <ruta>`.
- No versionar `__pycache__` (ya en `.gitignore` y `.chezmoiignore`).

## Pendiente / futuro
- **Fase C (otra sesión):** confirmar relogin de Hyprland (`.conf`), **rofi** (tema Mocha) + **mako** propia.
- **Objetivo final estético:** evolucionar a **Quickshell** (estilo `github.com/ilyamiro/nixos-configuration`)
  como fase aparte. Recordárselo al usuario al entrar en ello.
- **git push:** hay commits locales; subir a remoto **solo cuando el usuario lo pida**.
