# CLAUDE.md — Reglas del repo `kali-deox` (antes `arch-deox`)

Entorno **reproducible** sobre **Kali Linux** (rolling) para pentesting / hacking ético, con un
escritorio **Hyprland** propio, bonito y personalizable. Máquina: portátil Medion (Intel Iris Xe).
Usuario `deox`, nuevo en Linux.

> **Historia:** rice eDEX-UI sobre Arch (chezmoi, rama `main`) → CachyOS + Caelestia → **Kali**
> (decisión del usuario: Arch no le convenció). Todo lo anterior sigue en el historial git.

## Cómo trabajar aquí (IMPORTANTE)
1. **Planifica primero.** No toques el sistema del usuario hasta que apruebe el plan.
2. **El repo es un KIT DE INSTALACIÓN + dotfiles.** `scripts/` monta el sistema, `dotfiles/`
   tiene la configuración del escritorio (ya no hay Caelestia: la gestionamos nosotros),
   `packages/` las listas, `migracion/` el paso desde CachyOS.
3. **Pide confirmación antes de**: `sudo`, `apt install`, `rm`, `git push`, `dd`,
   `curl … | sh`, y antes de instalar algo pesado. Los scripts preguntan siempre (`ask`).
4. **Seguridad de lo que se instala** (pedido expreso del usuario): todo paquete nuevo debe
   (a) existir en el repo oficial de Kali, (b) pasar `deox-auditar --simular` sin
   `[ACTUALIZA YA]`, y (c) no arrastrar servicios innecesarios (ej. exim4). Nada de repos de
   terceros, PPAs, `curl | sh` ni binarios sueltos. Solo repos `kali-rolling` oficiales.
5. **Nunca** hagas commit de secretos (claves, `.gpg` de copias, contraseñas wifi).
6. **Family-friendly:** el usuario es nuevo. Explica lo que haces, **en español**, cercano.
7. **Antes de cada commit:** `bash tests/verificar.sh` (y en Kali con Hyprland instalado,
   valida la config con `Hyprland --verify-config`).

## Detalles técnicos a recordar
- **Hyprland ≥ 0.57 usa config en Lua** (`hyprland.lua`, API `hl.*`). El antiguo
  `hyprland.conf` ya NO se lee. `hyprlock`/`hypridle` siguen con su formato propio.
  `hyprctl dispatch` también usa sintaxis Lua: `hyprctl dispatch 'hl.dsp.exit()'`.
- Sesión: `start-hyprland` (envoltorio oficial). greetd en Debian/Kali corre como `_greetd`.
- Fondo con `swaybg` (vía `deox-fondo`), no hyprpaper.
- Colores: `dotfiles/temas/*.tema` + plantillas `*.tpl` → `deox-tema` las rellena en `~/.config`.
- Ajustes personales de Hyprland: `~/.config/hypr/usuario.lua` (se crea una vez, no se pisa).
- Kali rolling: siempre `apt full-upgrade`, nunca mezclar repos de Debian/Ubuntu.

## Estructura
- `migrar.sh` → entrada única (detecta CachyOS/Kali).
- `migracion/migrar-desde-cachyos.sh` → copia + ISO (GPG/SHA256) + USB + instrucciones.
- `scripts/` → `bootstrap.sh`, `10-sistema`, `20-escritorio`, `25-login`, `30-hacking`,
  `40-seguridad`, `50-snapshots`, `60-copia`, `instalar-dotfiles.sh`, `lib.sh`.
- `dotfiles/` → `hypr/ waybar/ rofi/ mako/ kitty/ wlogout/ fastfetch/ zsh/ temas/ bin/`.
- `packages/` → `base.txt`, `escritorio.txt`, `hacking-extra.txt`.
- `sistema/greetd-config.toml` · `tests/verificar.sh` · `docs/`.
