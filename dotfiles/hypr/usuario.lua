-- ~/.config/hypr/usuario.lua — TUS ajustes personales de Hyprland.
-- Se carga al final de hyprland.lua, así que lo que pongas aquí GANA.
-- El instalador solo lo copia si no existe: nunca te lo pisa.
-- Comprueba errores con:  Hyprland --verify-config
--
-- Ejemplos (quita los "--" del principio para activarlos):

-- Pantalla interna a 1920x1080@60 (mira el nombre real con: hyprctl monitors)
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })

-- Teclado en inglés + español, cambiando con Alt+Shift
-- hl.config({ input = { kb_layout = "es,us", kb_options = "grp:alt_shift_toggle" } })

-- Abrir Burp Suite con SUPER + SHIFT + B
-- hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("burpsuite"))

-- Menos huecos entre ventanas
-- hl.config({ general = { gaps_in = 3, gaps_out = 6 } })
