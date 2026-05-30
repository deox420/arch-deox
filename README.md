# arch-deox

Configuración **reproducible** para Arch Linux puro. El objetivo es levantar mi
sistema completo —base + dotfiles + ricing + herramientas de pentesting— en
cualquier dispositivo, ya sea desde una instalación limpia o desde un medio
portátil (ISO/USB).

- **Base:** Arch Linux puro (NO una derivada). [BlackArch](https://blackarch.org)
  se añade encima, por capas y por categorías.
- **Dotfiles:** [chezmoi](https://chezmoi.io) (fuente en `home/`, con `.chezmoiroot`).
- **Ricing:** Hyprland + Waybar + Rofi + Mako + Catppuccin/pywal.
- **Pentesting:** repo BlackArch vía `strap.sh`, instalado por grupos `blackarch-*`.
- **Medio portátil:** ISO custom con `archiso` (perfil `releng`) + persistencia con Ventoy.

> ⚠️ Las herramientas de pentesting son **solo para uso autorizado**.

## Estructura del repo

```
arch-deox/
├── README.md
├── CLAUDE.md                 # instrucciones para Claude Code
├── install.sh                # bootstrap: paru + pkglists + chezmoi + servicios
├── archinstall/              # config declarativa de archinstall
│   ├── user_configuration.json
│   └── user_disk_layout.json
├── packages/
│   ├── pkglist-native.txt    # pacman -Qqen
│   └── pkglist-aur.txt       # pacman -Qqem
├── ansible/                  # opcional, provisioning idempotente
├── home/                     # fuente chezmoi (.chezmoiroot apunta aquí)
│   └── dot_config/{hypr,waybar,rofi,mako,kitty}/
├── iso/                      # perfil archiso
└── pentest/                  # grupos BlackArch + menús XDG estilo Kali
```

## Migrar a una máquina nueva (de cero)

Flujo completo para tu primera instalación de Arch:

1. **Instalación limpia** con archinstall (ver Opción B). Resultado: Arch base
   arrancable con red, tu usuario `deox` y `git`/`chezmoi`.
2. **Primer arranque**: clonar este repo y correr `./install.sh` (Opción A).
   Esto trae paru, los paquetes y los dotfiles.
3. **(Solo la primera vez, EN el Arch real)** capturar el estado que no se
   puede generar desde otra máquina:
   ```bash
   # Listas de paquetes reales del sistema:
   pacman -Qqen > packages/pkglist-native.txt
   pacman -Qqem > packages/pkglist-aur.txt
   # Si afinas dotfiles, captúralos cifrando secretos:
   chezmoi add ~/.config/hypr ~/.config/waybar ~/.config/rofi
   git add -A && git commit -m "Snapshot inicial desde Arch" && git push
   ```
4. **(Opcional) capa de pentesting** BlackArch: ver `pentest/`.

> ⚠️ Este repo se está **autorizando desde una máquina que NO es Arch**, así que
> `pkglist-native.txt` y `pkglist-aur.txt` van vacías (solo cabecera) hasta que
> ejecutes el paso 3 en el Arch real. Los dotfiles de `home/` son una **baseline
> Catppuccin** lista para arrancar; ajústala a tu gusto.

### Opción A — desde un Arch ya instalado

```bash
git clone https://github.com/deox420/arch-deox.git
cd arch-deox

# Revisa primero qué hará, sin tocar nada:
./install.sh --dry-run

# Cuando estés conforme, ejecútalo de verdad:
./install.sh
```

`install.sh` es **idempotente** (se puede repetir sin romper nada) y hace:

1. Comprobaciones previas (Arch, no-root, red, sudo).
2. Instala el helper de AUR **paru** si falta.
3. Restaura paquetes nativos desde `packages/pkglist-native.txt` (`pacman -S --needed`).
4. Restaura paquetes del AUR desde `packages/pkglist-aur.txt` (`paru -S --needed`).
5. Despliega dotfiles: `chezmoi init --apply deox420`.
6. Habilita servicios básicos (NetworkManager, timesyncd, …).

Variables útiles:

```bash
SKIP_DOTFILES=1 ./install.sh   # no toca chezmoi
./install.sh --dry-run         # solo muestra lo que haría
```

### Opción B — instalación limpia con archinstall

Desde el entorno live de Arch (perfil: Ext4 sin cifrar · Europe/Madrid · es_ES ·
hostname `arch-deox` · usuario `deox`):

```bash
archinstall --config https://raw.githubusercontent.com/deox420/arch-deox/main/archinstall/user_configuration.json
```

Notas importantes (sobre todo si es tu **primera** instalación):

- **El disco**: `archinstall/user_disk_layout.json` trae `device` puesto a
  `/dev/CHANGEME` **a propósito** para no borrar el disco equivocado. Para la
  primera vez, lo más seguro es **elegir el disco interactivamente** dentro de
  archinstall (lo ves con `lsblk`) en lugar de cargar ese fichero.
- **Contraseñas**: NO están en el repo (regla de seguridad). Las pones en
  archinstall de forma interactiva, o en un `user_credentials.json` **local**
  (ya está en `.gitignore`).
- Verifica que las claves del JSON encajan con tu versión: `archinstall --version`.

Tras el primer arranque, sigue con la **Opción A** para dotfiles y paquetes.

### Solo dotfiles (sin paquetes)

```bash
chezmoi init --apply deox420
```

> Antes de aplicar en un sistema existente, revisa siempre el diff:
> `chezmoi diff`

## Capa de pentesting (BlackArch)

BlackArch se instala **encima** de Arch puro, por capas:

```bash
# 1) Añadir el repo BlackArch (strap.sh — revisa el script antes de ejecutarlo)
curl -O https://blackarch.org/strap.sh
# verifica el sha1 publicado, luego:
sudo bash strap.sh

# 2) Instalar por categorías, no todo de golpe (ver pentest/)
sudo pacman -S blackarch-webapp blackarch-recon   # ejemplo
```

Las listas de grupos y los menús XDG (clasificación estilo Kali) viven en `pentest/`.

## Mantenimiento de las listas de paquetes

Regenera las listas cuando cambien los paquetes instalados:

```bash
pacman -Qqen > packages/pkglist-native.txt   # nativos (repos oficiales)
pacman -Qqem > packages/pkglist-aur.txt      # foráneos (AUR)
```

## Seguridad

- **Nunca** se commitea ningún secreto (claves SSH/GPG, tokens, credenciales).
- Los secretos se cifran con **age** vía chezmoi (`chezmoi add --encrypt`).
- El `.gitignore` usa **allowlist**: ignora `*.key`, `*credentials*`, `cache/`,
  `history.jsonl`, etc.
- No se expone ningún servicio a internet sin evaluar el riesgo primero.

## Licencia

Pendiente de definir.
