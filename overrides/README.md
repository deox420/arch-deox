# overrides/ — tus ajustes personales sobre Caelestia

Caelestia gestiona sus propios dotfiles con `caelestia install`. Para no pelearte
con él, **no edites los ficheros que instala Caelestia**. En su lugar, mete aquí
tus cambios personales y cópialos al punto de override que Caelestia respeta.

## `hypr-user.conf` — Hyprland
Config principal de Caelestia carga un fichero de usuario **al final**, para que
tus líneas ganen. Pasos:

1. Tras `caelestia install`, mira qué fichero de usuario hace `source =` la
   config de Caelestia dentro de `~/.config/hypr/`. Suele ser uno de:
   - `~/.config/hypr/hyprland/user.conf`
   - `~/.config/hypr/custom/user.conf`
   ```bash
   grep -rn "source" ~/.config/hypr/ | grep -i user
   ```
2. Vuelca ahí el contenido de `overrides/hypr-user.conf` (monitor eDP-1, teclado
   ES, entorno Intel, tus atajos).
3. Recarga sin reiniciar:
   ```bash
   hyprctl reload
   hyprctl configerrors   # debe salir vacío
   ```

## `wallpaper/` — fondo de pantalla
Caelestia gestiona el wallpaper con su propio sistema (rota/aplica desde su
carpeta). Para poner el tuyo:

1. Copia tu imagen a la carpeta de wallpapers de Caelestia (verifica la ruta con
   `caelestia wallpaper --help` o en su config; suele ser `~/Pictures/Wallpapers`
   o `~/.config/caelestia/wallpapers`).
2. Aplícalo:
   ```bash
   caelestia wallpaper -f ~/Pictures/Wallpapers/tu-fondo.jpg
   ```

> Estos ficheros son **plantillas de referencia**. Las rutas exactas dependen de
> la versión de Caelestia instalada: confírmalas en tu máquina antes de copiar.
