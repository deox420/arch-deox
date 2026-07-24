# CLAUDE.md — Reglas del repo `arch-deox`

Entorno de escritorio **reproducible** sobre **CachyOS** (base Arch optimizada), con el
shell **Caelestia** (Quickshell sobre Hyprland). Máquina: portátil Medion (Intel Iris Xe).
Usuario `deox`, nuevo en Arch/CachyOS.

> **Historia:** este repo fue antes un rice eDEX-UI (Waybar/Rofi/Mako Catppuccin + kitty Tron
> + panel `deoxhud` + capa pentest/BlackArch) gestionado con **chezmoi**. Se migró por decisión
> del usuario a **CachyOS + Caelestia**, gestionando los dotfiles con **caelestia-cli** (ya no
> chezmoi). Todo lo anterior sigue en el historial git y en la rama `main`.

## Cómo trabajar aquí (IMPORTANTE)
1. **Planifica primero.** No toques el sistema hasta que el usuario apruebe el plan.
2. **El repo es un KIT DE INSTALACIÓN, no una fuente de dotfiles.** El escritorio lo despliega
   `caelestia install`. Este repo aporta: `scripts/` (arranque), `packages/` (listas),
   `overrides/` (ajustes personales) y `docs/`. No dupliques dentro del repo lo que ya gestiona
   Caelestia; para tweaks personales usa `overrides/`.
3. **Pide confirmación antes de**: `sudo`, `pacman -S`, `shelly -S` / `paru -S`, `rm`,
   `git push`, `curl … | sh`, y antes de instalar algo pesado.
4. **Nunca** hagas commit de secretos.
5. **Family-friendly:** el usuario es nuevo. Explica lo que haces, **en español**, cercano.

## Estructura
- `scripts/` → arranque por pasos: `00-post-install` (sistema+drivers Intel),
  `10-caelestia` (helper AUR + caelestia-cli + `caelestia install`),
  `20-login-manager` (greetd+tuigreet), `30-extras` (AUR/ufw/servicios).
- `packages/` → `pkglist-native.txt` (complementos oficiales) y `pkglist-aur.txt`
  (caelestia-cli + extras). `update-lists.sh` **audita** (no regenera) las listas.
- `overrides/` → ajustes personales que Caelestia respeta (Hyprland `user.conf`, wallpaper).
- `system/` → `greetd-config.toml` (va a `/etc/greetd/`, lo aplica `scripts/20-login-manager.sh`).
- `docs/` → `CONTEXTO-CAELESTIA.md` (punto de entrada) y `GUIA-CACHYOS-CAELESTIA.md` (novatos).

## Estética (decidida)
- **Caelestia shell** (Quickshell): barra, launcher, notificaciones, lockscreen, wallpaper.
- Compositor: **Hyprland** (lo configura Caelestia; tus tweaks van en `overrides/hypr-user.conf`).
- Terminal por defecto de Caelestia: **foot** + shell **fish**.

## Detalles del entorno
1. **CachyOS** = base del sistema (kernel optimizado + repos -march). Instalación limpia por ISO.
2. **Caelestia** = escritorio completo, desplegado y gestionado con `caelestia-cli`.
3. **greetd + tuigreet** = pantalla de login (Caelestia no trae gestor de login).
4. **Helper AUR**: en CachyOS 2026 por defecto es **`shelly`** (antes `paru`). Los scripts
   detectan cuál hay; ambos sirven para `caelestia-cli`.

## Reproducir en otra máquina
1. Instalar **CachyOS** (ISO + Calamares) con NetworkManager y perfil mínimo/Hyprland.
2. Clonar este repo y correr, en orden: `scripts/00…` → `10…` → (`caelestia install`) →
   `20…` → `30…` (opcional).
3. Copiar `overrides/` a las rutas que indica `overrides/README.md`. Reiniciar.
Ver `README.md` y `docs/GUIA-CACHYOS-CAELESTIA.md`.
