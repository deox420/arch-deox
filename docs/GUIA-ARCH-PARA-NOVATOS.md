# Guía de Arch Linux para novatos (y de este repo `arch-deox`)

Hola 👋. Esta guía está pensada para alguien que **viene de Windows o Ubuntu** y acaba de
estrenar Arch. Sin prisa, sin jerga innecesaria. Si algo no se entiende, no pasa nada: lee
despacio y prueba en tu propia máquina.

---

## 1. ¿Qué es Arch y en qué se diferencia?

- **Arch Linux** es una distribución "minimalista": instala **solo lo que tú decides**. No
  viene con escritorio ni programas de más. Por eso la has podido "ricear" (personalizar) a tu gusto.
- **Rolling release**: no hay "versiones" (como Ubuntu 22.04 → 24.04). Actualizas y siempre
  tienes lo último. La contrapartida: hay que **actualizar el sistema entero a la vez** (ver abajo).
- **La ArchWiki** (https://wiki.archlinux.org) es la mejor documentación de Linux que existe.
  Ante la duda, búscalo ahí.

### Diferencias que más despistan al venir de otro sitio

| Vienes de… | Allí | En Arch |
|---|---|---|
| Ubuntu/Debian | `apt install x` | `sudo pacman -S x` |
| Ubuntu/Debian | `apt update && apt upgrade` | `sudo pacman -Syu` (¡todo junto!) |
| Windows (PowerShell) | `irm url \| iex` | **NO existe** y **NO se hace**. Se instala con `pacman`/AUR. |
| Windows | "instalar un .exe" | Paquetes del repo o del AUR; los `.exe` no corren (sí con Wine, otra historia). |

> ⚠️ **Regla de oro de Arch:** **nunca** hagas un "parcial". Es decir, no instales un paquete
> suelto con la base de datos desactualizada. Actualiza siempre con `sudo pacman -Syu`
> (sincroniza + actualiza todo). Hacer `pacman -Sy paquete` (refrescar sin actualizar) puede
> **romper** el sistema. Ya nos pasó algo así al principio con un AUR helper precompilado.

---

## 2. Comandos de supervivencia

### Paquetes (pacman)
```bash
sudo pacman -Syu            # ACTUALIZAR todo el sistema (hazlo a menudo)
sudo pacman -S paquete      # instalar
sudo pacman -R paquete      # quitar (deja dependencias)
sudo pacman -Rns paquete    # quitar + dependencias huérfanas + configs
pacman -Qqe                 # listar lo que instalaste tú explícitamente
pacman -Qq paquete          # ¿está instalado? (sin error = sí)
pacman -Ss texto            # buscar en los repos
pacman -Si paquete          # info de un paquete
pacman -Qtdq                # listar huérfanos (deps que ya no usa nadie)
```

### AUR (paquetes de la comunidad) — con `paru`
```bash
paru -S paquete             # instalar desde AUR (o repos)
paru -Qua                   # ver actualizaciones del AUR
```
El **AUR** son "recetas" que compilan software no incluido en los repos oficiales. En este
equipo el ayudante es **`paru`**.

### Moverte por el sistema
```bash
ls        # listar (alias: ll = lista detallada, la = incluye ocultos)
cd ruta   # cambiar de carpeta;  cd ~  va a tu casa;  cd ..  sube una
pwd       # ¿dónde estoy?
cat fich  # ver un fichero;  less fich  para leerlo con scroll (q para salir)
nano fich # editar fácil (Ctrl+O guardar, Ctrl+X salir).  vim/nvim = avanzado
```

### Permisos y `sudo`
- `sudo` = "ejecuta esto como administrador (root)". Te pide tu contraseña.
- Solo lo necesitas para tocar el **sistema** (instalar, servicios, ficheros de `/etc`…).
- Tus **dotfiles** (en tu carpeta personal) **no** necesitan sudo.

### WiFi y red (NetworkManager)
```bash
nmtui                       # menú de texto para WiFi (lo más fácil)
nmcli device wifi list      # ver redes
nmcli device wifi connect "NOMBRE" password "CLAVE"
nmcli connection show --active   # conexiones activas
```

### Servicios (systemd)
```bash
systemctl status servicio       # ¿cómo está?
sudo systemctl start servicio   # arrancar ahora
sudo systemctl enable servicio  # que arranque al encender
sudo systemctl enable --now x   # las dos cosas a la vez
```
Ejemplos en este equipo: `bluetooth`, `power-profiles-daemon`, `NetworkManager`.

### Logs (cuando algo falla)
```bash
journalctl -xe              # últimos errores del sistema
journalctl -b               # logs desde el último arranque
dmesg | tail                # mensajes del kernel (hardware, drivers)
```

---

## 3. Qué hacer cuando algo falla (importante)

1. **Lee el error.** En Linux el error suele decir qué pasa. No lo ignores.
2. **No copies comandos a ciegas** de internet. Entiende qué hacen, sobre todo si llevan
   `sudo`, `rm`, o `| sh`.
3. **Busca en la ArchWiki** y en el foro de Arch. El 99% de los problemas ya le pasaron a alguien.
4. **Cambia una cosa cada vez.** Si tocas mil cosas y se rompe, no sabrás cuál fue.
5. **`rm -rf` es peligroso.** Borra sin preguntar y sin papelera. Mira dos veces la ruta.
6. Si una actualización rompe algo, mira los **avisos** que imprime pacman y la portada de la
   ArchWiki (sección "Latest news"): a veces hay un paso manual.

---

## 4. Cómo está organizado ESTE repo (`arch-deox`)

Todo tu entorno es **reproducible**: vive en un repositorio gestionado con **chezmoi**.

```
arch-deox/
├── home/                # tus dotfiles (chezmoi → tu carpeta personal)
│   ├── dot_config/      # = ~/.config (hypr, waybar, kitty, tmux, starship, fastfetch, cava, deoxhud)
│   ├── dot_local/bin/   # = ~/.local/bin (scripts: deoxhud, deoxhud-globe)
│   └── dot_bashrc       # = ~/.bashrc
├── packages/            # listas de paquetes para reinstalar
├── pentest/             # capa BlackArch (kit + docs) — ver pentest/README.md
└── docs/                # esta guía
```

### Las "capas" del entorno (independientes)
1. **Hyprland** = el escritorio (compositor de ventanas, Wayland).
2. **deoxhud** = tu panel sci-fi (estilo eDEX) en la terminal: globo-Tierra + reloj +
   calendario + monitor (btop) + terminal de trabajo. Se abre con el comando `deoxhud`.
3. **Cate** = app extra para "vibecoding" con IA (AppImage suelto, no en dotfiles).
4. **pentest** = herramientas de seguridad (capa BlackArch, bajo demanda).

### El ciclo de trabajo con chezmoi (¡clave!)
Los cambios de configuración van **primero al repo**, no a mano en `~/.config`:
```bash
chezmoi edit ~/.config/loquesea     # editar en la "fuente" (el repo)
chezmoi diff                        # ver qué cambiaría en tu sistema
chezmoi apply                       # aplicar los cambios a tu carpeta
chezmoi cd                          # ir al repo (git status, git commit, …)
```
Si editas un fichero a mano en `~/.config`, chezmoi se da cuenta; para "importarlo" al repo:
`chezmoi add ~/.config/eso`.

---

## 5. Reinstalar TODO desde cero (en otra máquina o tras formatear)

1. Instala Arch base (con `archinstall`), conéctate a internet e instala `git`.
2. Trae los dotfiles (sustituye `<usuario-github>` por el tuyo):
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <usuario-github>
   ```
3. Reinstala los paquetes:
   ```bash
   sudo pacman -S --needed - < packages/pkglist-native.txt   # oficiales
   paru  -S --needed - < packages/pkglist-aur.txt            # AUR (instala paru antes)
   ```
4. (Opcional) Capa pentest: ver `pentest/README.md`.
5. Reinicia sesión. Listo: deberías tener el mismo entorno.

---

## 6. Glosario mínimo

- **dotfiles**: ficheros de configuración (empiezan por punto, p.ej. `.bashrc`). Tu "personalización".
- **AUR** (Arch User Repository): repositorio comunitario de recetas para compilar software extra.
- **ricing**: personalizar el escritorio para que se vea bonito/a tu gusto.
- **compositor**: el programa que dibuja y gestiona las ventanas (aquí, **Hyprland**, en Wayland).
- **Wayland / X11**: las dos tecnologías gráficas de Linux. Hyprland usa Wayland (la moderna).
- **TTY**: una consola de texto pura (Ctrl+Alt+F2…F6). Útil si el escritorio no arranca.
- **display manager**: pantalla gráfica de login (aquí no usamos uno; Hyprland arranca desde TTY).
- **keyring**: las claves para verificar que los paquetes son auténticos.
- **meta-paquete**: un paquete que solo sirve para instalar muchos otros de golpe (p.ej. `blackarch`).

---

## 7. Seguridad y uso responsable

- **No expongas servicios a internet** sin saber lo que haces (SSH, bases de datos, paneles…).
  Un servicio abierto es una puerta; ciérrala si no la usas.
- Mantén el sistema **actualizado** (`sudo pacman -Syu`): muchos fallos de seguridad se
  arreglan así.
- **Herramientas de pentesting (BlackArch):** son potentes y muchas son "ofensivas". Úsalas
  **solo** en equipos/redes **tuyos** o con **permiso explícito por escrito**. Escanear o
  atacar sistemas ajenos es **ilegal** y tú eres el responsable. Para aprender, monta tu
  propio laboratorio (máquinas virtuales, retos tipo CTF, Hack The Box, etc.).

---

¿Dudas? Lee el error, busca en la ArchWiki, y cambia una cosa cada vez. Se aprende rompiendo
(en tu laboratorio) y arreglando. 🐧
