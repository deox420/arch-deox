# ~/.config/hypr/hyprlock.conf — pantalla de bloqueo. GENERADO por deox-tema (@@nombre@@).
$font = JetBrains Mono

general {
    hide_cursor = true
}

animations {
    enabled = true
    bezier = linear, 1, 1, 0, 0
    animation = fadeIn, 1, 5, linear
    animation = fadeOut, 1, 5, linear
    animation = inputFieldDots, 1, 2, linear
}

background {
    monitor =
    path = @@wallpaper@@
    blur_passes = 3
    blur_size = 6
    brightness = 0.6
}

input-field {
    monitor =
    size = 22%, 5%
    outline_thickness = 3
    inner_color = rgba(@@bg2@@cc)
    outer_color = rgba(@@accent@@ee) rgba(@@accent2@@ee) 45deg
    check_color = rgba(@@ok@@ee) rgba(@@accent2@@ee) 120deg
    fail_color = rgba(@@err@@ee) rgba(@@magenta@@ee) 40deg
    font_color = rgb(@@fg@@)
    fade_on_empty = false
    rounding = 12
    font_family = $font
    placeholder_text = <i>contraseña…</i>
    fail_text = $PAMFAIL
    dots_spacing = 0.3
    position = 0, -40
    halign = center
    valign = center
}

# Hora
label {
    monitor =
    text = $TIME
    color = rgb(@@fg@@)
    font_size = 96
    font_family = $font
    position = 0, 160
    halign = center
    valign = center
}

# Fecha
label {
    monitor =
    text = cmd[update:60000] LC_TIME=es_ES.UTF-8 date +"%A, %d de %B"
    color = rgb(@@fg_dim@@)
    font_size = 22
    font_family = $font
    position = 0, 70
    halign = center
    valign = center
}

# Firma
label {
    monitor =
    text =  kali-deox :: $USER
    color = rgb(@@accent2@@)
    font_size = 14
    font_family = $font
    position = 0, 30
    halign = center
    valign = bottom
}
