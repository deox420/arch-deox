# CONTEXTO COMPLETO — arch-deox (punto de entrada para una sesión nueva)

> **Empieza por aquí.** Este documento fusiona el trabajo de las DOS sesiones que montaron
> el entorno: la **sesión terminal/sistema** (Fases A, B, D, E, F, G, H) y la **sesión
> escritorio** (Fase C). Al 2026-06-01 el **plan A–H está COMPLETO y verificado**.
> Detalle por sesión: `docs/HANDOFF-sesion-terminal.md`. Reglas del repo: `CLAUDE.md`.

---

## 0. Qué es esto
Entorno **Arch Linux riceado y reproducible** (gestionado con **chezmoi**), estética
**eDEX-UI / sci-fi**. Portátil Medion (Intel i5-1155G7, Iris Xe, eDP-1 1920x1080).
Usuario `deox`, **nuevo en Arch → explicar todo en español**. Fuente chezmoi en
`~/.local/share/chezmoi` (`.chezmoiroot = home`, rama git `main`).

Capas independientes: **Hyprland** (compositor) · **deoxhud** (panel sci-fi a demanda) ·
**Cate** (AppImage IA, opcional). Estética: **Catppuccin Mocha** en escritorio + **neón Tron**
(cian/verde) en terminal.

---

## 1. Estado actual: PLAN A–H COMPLETO ✅

| Fase | Qué | Estado |
|------|-----|--------|
| **A** | Repo chezmoi + git + estructura + CLAUDE/README/.chezmoiignore | ✅ |
| **B** | Drivers Intel (vulkan-intel, intel-media-driver, libva-utils) + **paru** | ✅ |
| **C** | Escritorio Catppuccin: Hyprland, Waybar, Rofi, Mako, wallpaper | ✅ |
| **D** | Terminal eDEX: kitty/tmux/starship/fastfetch/cava + **deoxhud** | ✅ |
| **E** | Sistema: neovim, fzf/rg/fd/bat/eza/zoxide, bluez, PPD; pkglists | ✅ |
| **F** | Cate AppImage v1.1.0 + lanzador | ✅ |
| **G** | BlackArch (capa) + kit curado 31 herramientas | ✅ |
| **H** | Guía novatos + README reproducibilidad | ✅ |

**Verificado:** `chezmoi status` vacío · `hyprctl configerrors` vacío · `systemctl --failed`
ninguno · bluetooth/power-profiles-daemon/NetworkManager activos · `vainfo` OK · `deoxhud`
levanta el layout · BlackArch repo + kit 31/31 · Cate abre · wallpaper activo.

---

## 2. Lo que hizo la SESIÓN ESCRITORIO (Fase C) — IMPORTANTE

- **Hyprland está en `.conf` (hyprlang), NO en Lua.** Se migró a Lua y luego **se REVIRTIÓ**:
  el modo Lua de Hyprland **0.55.2 rompe el IPC clásico** (clic en Waybar, `dispatch exec/exit`,
  scripts externos → `return hl.dispatch(...)` peta). En `.conf` todo funciona. Config en
  `home/dot_config/hypr/hyprland.conf`, sin `configerrors`.
  - `togglesplit` no es dispatcher → se usa `layoutmsg, togglesplit`.
  - **`windowrule` está deprecada/rota** en el parser `.conf` de 0.55.2 (`invalid field float`
    con cualquier sintaxis) → se quitaron; sintaxis de reañadido documentada dentro del .conf.
- **Waybar**: barra superior sólida, módulos en píldoras con icono+etiqueta, Catppuccin Mocha,
  `persistent-workspaces: 5` (5 pestañas siempre visibles), módulo power-profiles-daemon,
  menú de energía (`waybar/executable_power-menu.sh`).
- **Rofi 2.0** (trae backend Wayland nativo; NO `rofi-wayland`): tema Catppuccin en
  `rofi/config.rasi` + `rofi/catppuccin-mocha.rasi`, iconos **Papirus-Dark**. `$menu = rofi -show drun`.
  - Gotcha: para usar `Tab` como cambio de modo hay que **liberar** `kb-element-next=""` y
    `kb-element-prev=""` (si no, rofi muestra error de conflicto de teclas en su ventana).
- **Mako**: `mako/config` Catppuccin (borde cian, críticas en rojo sin timeout). Recargar: `makoctl reload`.
- **Wallpaper**: `~/.local/share/wallpapers/rat-hacker.jpg` (fuera del repo; ruta sin acentos
  y neutra de idioma). `hyprpaper.conf.tmpl` usa `{{ .chezmoi.homeDir }}` (hyprpaper NO expande `~`).
  ⚠️ **Bug hyprpaper 0.8.4**: al arrancar detecta el monitor antes de precargar y NO pinta el
  fondo (log "Monitor eDP-1 has no target"); no es la ruta/acentos/espacio (verificado con
  config ASCII mínima) sino una carrera. **Fix**: el autostart usa `~/.local/bin/deox-wallpaper`
  (arranca hyprpaper y reintenta `hyprctl hyprpaper wallpaper "eDP-1,RUTA"` —sin espacio— hasta
  que `listactive` lo confirma). Para cambiar de fondo: copia otra imagen ahí y ajusta la ruta
  en `hyprpaper.conf.tmpl` + `deox-wallpaper`.

---

## 3. Lo que hizo la SESIÓN TERMINAL (A, B, D, E, F, G, H)
Resumen (detalle en `HANDOFF-sesion-terminal.md`):
- **deoxhud** (`~/.local/bin/{deoxhud,deoxhud-globe}`): dashboard tmux = globo-Tierra ASCII
  girando + reloj/calendario ES + btop (config compacta `~/.config/deoxhud/btop-panel.conf`)
  + terminal de trabajo. Layout adaptable con `tput` (btop nunca da "too small").
  **Gotcha:** si la sesión tmux ya existe, **reconecta**; para rehacerla `tmux kill-session -t deoxhud`.
- **paru** compilado **de fuente** (el `-bin` fallaba por `libalpm.so`). OJO: paru NO está
  en repos oficiales; está en el repo **blackarch** (verificado 2026-06-12). En máquina limpia:
  clonar de AUR + `makepkg -si` (como dice el README).
- **Sistema**: utilidades modernas (fzf/rg/fd/bat/eza/zoxide/tree) integradas en `.bashrc`;
  bluez+blueman, pavucontrol, PPD.
- **Cate**: AppImage v1.1.0 + `.desktop` (necesita fuse2).
- **BlackArch**: `strap.sh` verificado por SHA1; kit curado de 31 tools en `pentest/`.

---

## 4. Reglas de trabajo (de CLAUDE.md) — RESPETAR SIEMPRE
1. **Dotfiles en el repo PRIMERO** → `chezmoi diff` → mostrar → **confirmar** → `chezmoi apply`.
2. **Confirmar antes de**: `sudo`, `pacman -S`, `paru -S`, `rm`, `git push`, `curl|sh`, instalar algo pesado.
3. **`sudo` lo ejecuta el USUARIO** en su terminal (la sesión no tiene tty para la contraseña;
   sugerir `!sudo …` o que lo corra él).
4. `chezmoi apply` puede pedir TTY si un fichero se editó a mano → `chezmoi apply --force <ruta>`.
5. **Cada sesión commitea solo sus ficheros**; commits locales, **`git push` solo si lo pide deox**.
6. Base Arch **pura**; BlackArch solo como **capa por categorías** (nunca el meta-grupo).
7. Explicar todo **en español**, cercano (usuario novato).

## 5. Estructura del repo
```
~/.local/share/chezmoi/        (rama main)
├── CLAUDE.md  README.md  .chezmoiignore  .gitignore
├── home/                       # .chezmoiroot → $HOME
│   ├── .chezmoiignore  dot_bashrc
│   ├── dot_config/{hypr,waybar,rofi,mako,kitty,tmux,fastfetch,cava,deoxhud,starship.toml}
│   └── dot_local/bin/{executable_deoxhud,executable_deoxhud-globe}
├── packages/{pkglist-native.txt,pkglist-aur.txt}
├── pentest/{categorias.txt,kit-curado.txt,install-kit.sh,README.md}
└── docs/{CONTEXTO-COMPLETO.md (este), HANDOFF-sesion-terminal.md, GUIA-ARCH-PARA-NOVATOS.md}
```

## 6. Memoria (Claude) relacionada
- `project-arch-deox` — estado y decisiones del proyecto.
- `user-deox` — perfil del usuario (novato, español, portátil Intel).
- `ref-aesthetic-goal` — meta estética final (Quickshell estilo ilyamiro/nixos-configuration).

---

## 7. Mantenimiento 2026-06-12 (auditoría completa del repo)
Sesión de revisión: bugs corregidos y mejoras aplicadas (commits `9715bb7..`):
- **Sincronización repo↔sistema**: el exec-once de `dbus-update-activation-environment` y el
  bind SUPER+SHIFT+P (modo-ponencia) solo vivían en el sistema → ya en el repo. Versionados
  `modo-ponencia` y `proyector` (estaban huérfanos en `~/.local/bin`). `system/` commiteado.
- **Agente polkit**: faltaba su exec-once (apps gráficas con privilegios fallaban en silencio).
- **hyprlock** ahora es `.tmpl` y usa el wallpaper propio (antes un PNG genérico).
- **Multi-monitor**: mako sin `output=eDP-1`; `deox-wallpaper` aplica a todos los monitores.
- **Waybar**: `sort-by-number` (deprecado) → `sort-by: number`. **power-menu**: wofi → rofi.
- **Paquetes**: listas separadas por origen (`pkglist-native/blackarch/aur`) con
  `packages/update-lists.sh`; antes la nativa mezclaba 15 paquetes de blackarch y rompía la
  reinstalación limpia. `install-kit.sh`: `-Sy` → `-Syu` (evita partial upgrade).
- **Portapapeles**: cliphist + wl-clip-persist (SUPER+CTRL+V = historial con rofi).
- **Nuevos paquetes**: qt5/qt6-wayland, gvfs, tumbler, thunar-volman, noto-fonts(+emoji),
  bash-completion, cliphist, wl-clip-persist, ufw (firewall deny-in/allow-out), greetd+tuigreet.

## 8. PENDIENTE (decisión del usuario, fuera del plan base)
- **git push**: hay commits locales en `main`, **sin remoto configurado** y sin `gh`. Para subir:
  crear repo en GitHub, `git remote add origin <url>`, configurar auth (SSH o token), `git push -u origin main`.
- **Evolución a Quickshell**: objetivo estético final (Quickshell + Hyprland, estilo
  `github.com/ilyamiro/nixos-configuration`). Es un **proyecto aparte y grande**; abordar como nueva fase.
