# Temas

Cada `*.tema` es una lista de colores. `deox-tema <nombre>` rellena con ellos las
plantillas `*.tpl` de `dotfiles/` y recarga Hyprland, Waybar, Mako y Kitty en caliente.

- Ver temas:      `deox-tema --lista`
- Cambiar:        `deox-tema tron`   (o `SUPER + T` para elegir con menú)
- Crear el tuyo:  copia `kali-glitch.tema` a `mitema.tema`, cambia los colores y
                  ejecuta `deox-tema mitema`.

Claves obligatorias: `nombre bg bg2 bg3 fg fg_dim accent accent2 ok warn err magenta wallpaper`
(colores en hex de 6 cifras, sin `#`). `wallpaper` es una ruta a una imagen.
