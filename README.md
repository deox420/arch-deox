# kali-deox

Kit **reproducible** para mi portátil (Medion, Intel Iris Xe): **Kali Linux** con todas las
herramientas de hacking ético y un escritorio **bonito y personalizable** — Hyprland con
barra, lanzador, notificaciones, pantalla de bloqueo y temas de color intercambiables.

Incluye el **instalador de migración** desde mi CachyOS anterior: copia verificada y cifrada
de mis datos, ISO de Kali con la firma oficial comprobada y pendrive grabado sin riesgo.

| | |
|---|---|
| **Sistema** | [Kali Linux](https://www.kali.org) rolling (base Debian testing) |
| **Escritorio** | Hyprland 0.57 (config en **Lua**) · Waybar · Rofi · Mako · Hyprlock/Hypridle · wlogout |
| **Terminal** | Kitty + zsh (el de Kali) + Starship + fastfetch |
| **Login** | greetd + tuigreet (modo texto) |
| **Temas** | `kali-glitch` (defecto) · `kali-noche` · `tron` · `catppuccin` — `SUPER+T` |
| **Hacking** | `kali-linux-default` o `-large` + extras modernos (netexec, bloodhound, ligolo-ng, nuclei, caido…) |
| **Seguridad** | Cada instalación se **audita** contra CVEs conocidos (`deox-auditar`), ufw, AppArmor, aviso semanal |

## Empezar

**Estoy en CachyOS** (preparar el salto):
```bash
cd ~/arch-deox && git pull     # o clónalo si no lo tienes
bash migrar.sh                 # copia → ISO verificada → USB → instrucciones
```

**Ya estoy en Kali** (montar todo):
```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/deox420/arch-deox.git ~/kali-deox && cd ~/kali-deox
bash migrar.sh                 # detecta Kali y lanza scripts/bootstrap.sh
```

Paso a paso para novatos: **[docs/GUIA-KALI.md](docs/GUIA-KALI.md)** ·
Atajos: **[docs/ATAJOS.md](docs/ATAJOS.md)** · Seguridad: **[docs/SEGURIDAD.md](docs/SEGURIDAD.md)**

## Estructura

| Carpeta | Contenido |
|---|---|
| `migrar.sh` | Punto de entrada único: en CachyOS prepara la migración; en Kali monta el entorno. |
| `migracion/` | `migrar-desde-cachyos.sh`: copia de datos (sha256 + secretos cifrados AES-256), descarga de la ISO con verificación GPG, grabación segura del USB. |
| `scripts/` | `bootstrap.sh` y los pasos `10-sistema` · `20-escritorio` (+`25-login`) · `30-hacking` · `40-seguridad` · `50-snapshots` · `60-copia` · `instalar-dotfiles.sh` · `lib.sh`. |
| `dotfiles/` | Configuración del escritorio: `hypr/` (Lua), `waybar/`, `rofi/`, `mako/`, `kitty/`, `wlogout/`, `fastfetch/`, `zsh/`, `temas/`, `bin/` (scripts `deox-*`). Los `*.tpl` son plantillas que rellena `deox-tema`. |
| `packages/` | `base.txt` · `escritorio.txt` · `hacking-extra.txt` (verificados contra el repo de Kali). |
| `sistema/` | `greetd-config.toml` (va a `/etc/greetd/`). |
| `tests/` | `verificar.sh`: revisa scripts, JSON, temas y la config de Hyprland antes de cada commit. |
| `docs/` | Guía para novatos, atajos y política de seguridad. |

## Personalizar

- **Colores:** `SUPER+T` o `deox-tema tron`. Crea el tuyo copiando un `dotfiles/temas/*.tema`.
- **Fondo:** `deox-fondo ~/Imágenes/mi-fondo.jpg`.
- **Hyprland:** tus cambios en `~/.config/hypr/usuario.lua` (nunca se sobrescribe).
- **Modo "versionado":** `bash scripts/instalar-dotfiles.sh --enlazar` → editas en el repo y
  haces commit.

> **Historia:** antes fue un rice eDEX-UI sobre Arch (rama `main`, historial git) y luego
> CachyOS + Caelestia. Se migró a Kali por decisión del usuario; todo lo anterior sigue en git.

Reglas del repo: [CLAUDE.md](CLAUDE.md). ⚖ Herramientas solo contra sistemas propios o con
permiso por escrito.
