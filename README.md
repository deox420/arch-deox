# arch-deox

Kit **reproducible** para montar mi escritorio sobre **CachyOS** con el shell **Caelestia**
(Quickshell sobre Hyprland). No son dotfiles sueltos: es el guion de arranque + listas de
paquetes + ajustes personales para dejar el portátil listo tras una instalación limpia.

- **Base del sistema:** [CachyOS](https://cachyos.org) (Arch optimizado, kernel `linux-cachyos`)
- **Escritorio:** [Caelestia](https://github.com/caelestia-dots/caelestia) — barra, launcher,
  notificaciones, lockscreen y wallpaper, gestionado con `caelestia-cli`
- **Compositor:** Hyprland (lo configura Caelestia) · **Terminal:** foot + fish
- **Login:** greetd + tuigreet · **Hardware de referencia:** portátil Medion, Intel Iris Xe

> **Antes** esto era un rice eDEX-UI con chezmoi (Waybar/Rofi/Mako + kitty Tron + `deoxhud` +
> capa pentest/BlackArch). Se migró a CachyOS + Caelestia. Lo anterior sigue en la rama `main`
> y en el historial git por si quieres recuperar algo.

## Estructura

| Carpeta | Contenido |
|---|---|
| `scripts/` | Arranque por pasos: `00-post-install` (sistema + drivers Intel), `10-caelestia` (helper AUR + `caelestia-cli` + `caelestia install`), `20-login-manager` (greetd+tuigreet), `30-extras` (AUR/firewall/servicios). |
| `packages/` | `pkglist-native.txt` (complementos de repos oficiales), `pkglist-aur.txt` (caelestia-cli + extras). `update-lists.sh` audita las listas contra lo instalado. |
| `overrides/` | Ajustes personales que Caelestia respeta: `hypr-user.conf` (monitor, teclado, Intel) y wallpaper. |
| `system/` | `greetd-config.toml` (config del login, va a `/etc/greetd/`). |
| `docs/` | `CONTEXTO-CAELESTIA.md` (empieza aquí) y `GUIA-CACHYOS-CAELESTIA.md` (paso a paso para novatos). |

## Reproducir desde cero (resumen)

1. **Instala CachyOS** con su ISO (instalador Calamares): elige NetworkManager y un perfil
   mínimo o Hyprland. Arranca en el sistema nuevo y conéctate a internet.
2. **Clona este repo:**
   ```bash
   git clone https://github.com/deox420/arch-deox.git && cd arch-deox
   ```
3. **Base del sistema + drivers Intel:**
   ```bash
   bash scripts/00-post-install.sh
   ```
4. **Caelestia** (helper AUR + `caelestia-cli`), y luego el despliegue interactivo:
   ```bash
   bash scripts/10-caelestia.sh
   caelestia install        # elige componentes: hypr, fish, foot, temas, etc.
   ```
5. **Login** greetd + tuigreet:
   ```bash
   bash scripts/20-login-manager.sh
   ```
6. **Extras opcionales** (AUR, firewall ufw, bluetooth):
   ```bash
   bash scripts/30-extras.sh
   ```
7. **Tus ajustes personales:** copia `overrides/` a las rutas que indica
   [`overrides/README.md`](overrides/README.md) y **reinicia**.

> ¿Nuevo en esto? Lee **[docs/GUIA-CACHYOS-CAELESTIA.md](docs/GUIA-CACHYOS-CAELESTIA.md)**.

## Reglas del repo
Ver [CLAUDE.md](CLAUDE.md). Resumen: el repo es un **kit de instalación** (los dotfiles los
gestiona `caelestia install`, no chezmoi); confirmar antes de `sudo`/instalar/`push`; sin
secretos; tweaks personales en `overrides/`; explicar todo en español.
