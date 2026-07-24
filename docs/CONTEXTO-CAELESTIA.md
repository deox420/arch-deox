# CONTEXTO — arch-deox (CachyOS + Caelestia) · punto de entrada

> **Empieza por aquí** si abres una sesión nueva. Resume qué es el repo hoy, por qué cambió,
> y en qué estado está. Reglas: `CLAUDE.md`. Guía paso a paso: `GUIA-CACHYOS-CAELESTIA.md`.

---

## 0. Qué es esto
Kit **reproducible** para montar el escritorio de `deox` sobre **CachyOS** (base Arch
optimizada) con el shell **Caelestia** (Quickshell sobre Hyprland). Portátil Medion
(Intel i5-1155G7, Iris Xe, panel eDP-1 1920x1080). Usuario nuevo → **explicar todo en español**.

El repo **ya no usa chezmoi**: los dotfiles del escritorio los despliega y gestiona
`caelestia install` (paquete `caelestia-cli`). El repo aporta el guion de arranque
(`scripts/`), las listas de paquetes (`packages/`), los ajustes personales (`overrides/`)
y la documentación (`docs/`).

## 1. Por qué cambió (migración)
El repo nació como rice **eDEX-UI** (Hyprland + Waybar/Rofi/Mako Catppuccin, kitty Tron,
panel `deoxhud`, capa pentest/BlackArch) con **chezmoi**. La meta estética final siempre fue
**Quickshell**. El usuario decidió el salto completo:
- **CachyOS** en vez de Arch puro (instalación limpia por ISO).
- **Caelestia** en vez del rice propio (todo de cero).
- **caelestia-cli** en vez de chezmoi para gestionar los dotfiles.

Todo lo anterior queda intacto en la rama `main` y el historial git (recuperable).

## 2. Capas del entorno (independientes)
1. **CachyOS** = base (kernel `linux-cachyos`, repos -march, helper AUR `shelly` por defecto).
2. **Caelestia** = escritorio completo (barra, launcher, notis, lockscreen, wallpaper) sobre
   **Hyprland**; terminal **foot** + shell **fish**.
3. **greetd + tuigreet** = pantalla de login (Caelestia no trae gestor de login).

## 3. Estado actual del repo
- `scripts/` — scripts idempotentes, interactivos, en español: `bootstrap.sh` (orquestador,
  reconstrucción exprés) + `00→10→20→30` + `40-snapshots` (Btrfs/snapper + rollback) +
  `50-backup` (copia externa de datos personales).
- `packages/pkglist-native.txt` — complementos oficiales (drivers Intel, greetd, brillo/sensores,
  red/ufw, utilidades de terminal, grim/slurp). **No** es la lista completa: el grueso lo pone
  Caelestia.
- `packages/pkglist-aur.txt` — `caelestia-cli` + extras comentados.
- `packages/update-lists.sh` — auditoría no destructiva (compara instalado vs. listas).
- `overrides/` — `hypr-user.conf` (monitor eDP-1, teclado ES, entorno Intel) + `wallpaper/` +
  `README.md` con el punto de override de Caelestia.
- `system/greetd-config.toml` — config de login (reutilizada de la etapa anterior).
- `docs/` — este contexto + la guía para novatos.

## 4. Datos técnicos de referencia (verificados 2026-07)
- **Caelestia**: instalación oficial `<<helper>> -S caelestia-cli` → `caelestia install`
  (lee `manifest.toml`, elige componentes). Deps núcleo: quickshell(-git), ddcutil,
  brightnessctl, libcava, networkmanager, lm-sensors, libpipewire, libqalculate, aubio, fish,
  material-symbols, ttf-jetbrains-mono-nerd. Recomienda **greetd + tuigreet**.
- **CachyOS 2026**: instalador Calamares con opción Hyprland; helper AUR por defecto **`shelly`**
  (paru salió del instalador pero se puede compilar a mano). Los scripts soportan ambos.
- **Hardware Intel Iris Xe**: `vulkan-intel intel-media-driver libva-utils intel-ucode`;
  `env = LIBVA_DRIVER_NAME,iHD`. Comprobar con `vainfo`.

## 5. Reglas de trabajo (de CLAUDE.md) — RESPETAR
1. El repo es un **kit de instalación**, no fuente de dotfiles. Tweaks personales → `overrides/`.
2. **Confirmar antes de**: `sudo`, `pacman -S`, `shelly/paru -S`, `rm`, `git push`, `curl|sh`.
3. `sudo` lo ejecuta el **usuario** en su terminal (la sesión no tiene tty para la contraseña).
4. Sin secretos en commits. Explicar todo **en español**, cercano (usuario novato).

## 5b. Reconstrucción exprés / volver atrás (CachyOS Btrfs)
Objetivo del usuario: poder cambiar/reinstalar rápido y sin miedo. Enfoque:
- **Sistema desechable** → se rehace con `scripts/bootstrap.sh` (encadena 00→10→…→40).
- **Rollback de actualización rota** → CachyOS/Btrfs hace snapshot automático antes de cada
  `pacman` (snapper + snap-pac + limine-snapper-sync). Reiniciar → elegir Snapshot en el menú
  de arranque → `sudo snapper rollback`. `40-snapshots.sh` lo verifica/completa.
- **Datos personales** (no cubiertos por snapshots ante fallo de disco) → copia externa con
  `50-backup.sh` (rsync de una lista curada de carpetas de $HOME).

## 6. Pendiente / ideas
- Ajustar `overrides/hypr-user.conf` a la ruta real de override tras `caelestia install`
  (verificar en la máquina; ver `overrides/README.md`).
- Elegir wallpaper personal y fijarlo con `caelestia wallpaper`.
- Revisar `packages/` con `update-lists.sh` una vez montado, por si falta/sobra algo.
