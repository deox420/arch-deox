# Guía para novatos — CachyOS + Caelestia paso a paso

Esta guía te lleva de la mano desde una máquina vacía hasta el escritorio Caelestia
funcionando. Está pensada para alguien **nuevo** en Arch/CachyOS. Ve con calma y lee cada
paso antes de ejecutarlo. Si algo pide contraseña de `sudo`, es normal: es tu contraseña.

> Regla de oro: **entiende antes de pulsar Enter**. Todos los scripts te preguntan `[s/N]`
> antes de tocar nada; si dudas, responde `N` y pregunta.

---

## 1. Instalar CachyOS
1. Descarga la ISO desde https://cachyos.org y grábala en un USB (con Ventoy, Impression,
   o `dd`). Arranca el portátil desde el USB (tecla F-algo al encender: F2/F8/F12/Supr).
2. Se abre el instalador gráfico (**Calamares**). Sigue el asistente:
   - **Teclado**: Español.
   - **Disco**: si vas a formatear el portátil entero, elige "borrar disco". ⚠️ Esto **borra
     todo**: haz copia de tus cosas antes.
   - **Escritorio/perfil**: elige **Hyprland** o un perfil mínimo. Caelestia traerá su propia
     configuración encima, así que no te compliques.
   - **Red**: deja **NetworkManager** activado.
3. Reinicia, quita el USB, entra en tu CachyOS nuevo y conéctate a internet.

## 2. Traerte este repo
Abre una terminal y clona el kit:
```bash
sudo pacman -S --needed git      # por si git no está
git clone https://github.com/deox420/arch-deox.git
cd arch-deox
```

## 3. Base del sistema + drivers Intel
```bash
bash scripts/00-post-install.sh
```
Te preguntará si actualizar el sistema (di que sí), si instalar los **drivers Intel** (sí,
tu portátil los necesita para el vídeo) y si instalar las utilidades de `packages/`.
Al final comprueba el vídeo:
```bash
vainfo      # debe listar perfiles H264/HEVC → aceleración Intel OK
```

## 4. Instalar Caelestia
```bash
bash scripts/10-caelestia.sh
```
Este script:
- Busca tu **helper de AUR** (`shelly` viene por defecto en CachyOS; si no, te ofrece
  compilar `paru`).
- Instala **`caelestia-cli`** (arrastra Quickshell y dependencias).

Cuando termine, lanza **tú a mano** el despliegue (es interactivo, para elegir componentes):
```bash
caelestia install
```
Deja activados al menos: `hypr`, `fish`, `foot`, `fonts`, `gtk`, `qt`, `auth`, `network`,
`bluetooth`, `pipewire`, `clipboard`, `tools`. Los demás (spotify, vscode, zen…) a tu gusto.

## 5. Pantalla de login (greetd + tuigreet)
Caelestia no trae login propio, así que ponemos uno:
```bash
bash scripts/20-login-manager.sh
```
Instala greetd + tuigreet, copia la config a `/etc/greetd/config.toml` y lo activa para el
próximo arranque. Si el script avisa de que hay **otro** gestor de login activo, desactívalo
como te indica antes de seguir.

## 6. Extras opcionales
```bash
bash scripts/30-extras.sh
```
Paquetes de AUR (los de `packages/pkglist-aur.txt`), **firewall ufw** (recomendado) y
**bluetooth** al arranque. Salta lo que no quieras.

## 7. Tus ajustes personales (overrides)
Caelestia gestiona sus propios ficheros; **no los edites directamente**. Para tus cambios:
1. Mira dónde deja Caelestia su fichero de usuario de Hyprland:
   ```bash
   grep -rn "source" ~/.config/hypr/ | grep -i user
   ```
2. Copia ahí el contenido de `overrides/hypr-user.conf` (monitor eDP-1, teclado ES, Intel).
3. Recarga y comprueba:
   ```bash
   hyprctl reload
   hyprctl configerrors     # vacío = bien
   ```
Detalle completo (incluido el wallpaper) en [`../overrides/README.md`](../overrides/README.md).

## 8. Reiniciar y disfrutar
```bash
reboot
```
Al volver deberías ver el login de tuigreet; entra y arrancará Hyprland con el shell Caelestia.

---

## Comprobaciones rápidas (si algo va raro)
```bash
hyprctl configerrors     # errores de configuración de Hyprland (debe estar vacío)
systemctl --failed       # servicios caídos
systemctl is-enabled greetd.service
vainfo                   # aceleración de vídeo Intel
caelestia --help         # comandos del shell (wallpaper, etc.)
```

## Palabras que verás (mini glosario)
- **CachyOS**: Arch optimizado (más rápido); por debajo es Arch, así usas `pacman`.
- **AUR**: repositorio comunitario. Se instala con un *helper* (`shelly` o `paru`).
- **Caelestia / Quickshell**: el escritorio bonito (barra, menús, notificaciones).
- **Hyprland**: el que coloca y mueve las ventanas (compositor Wayland).
- **greetd/tuigreet**: la pantalla donde metes tu usuario y contraseña al arrancar.
