-- ~/.config/hypr/hyprland.lua — escritorio "kali-deox" (Hyprland >= 0.57, config en Lua)
-- ---------------------------------------------------------------------------
-- Desde Hyprland 0.57 la configuración es Lua (adiós al antiguo hyprland.conf).
-- Este fichero lo gestiona el repo: para TUS cambios usa ~/.config/hypr/usuario.lua,
-- que se carga al final y nunca se sobrescribe.
--
-- Colores: vienen de colores.lua, que genera `deox-tema` (no lo edites a mano).
-- Comprobar errores sin reiniciar:  Hyprland --verify-config
-- Wiki oficial: https://wiki.hypr.land/configuring/
-- ---------------------------------------------------------------------------

-- Colores del tema activo (con valores de reserva por si aún no existe el fichero).
local ok, c = pcall(require, "colores")
if not ok or type(c) ~= "table" then
    c = {
        accent   = "rgba(2f6bffee)",
        accent2  = "rgba(00d4ffee)",
        inactive = "rgba(1f2b5caa)",
        shadow   = "rgba(0a0e1fee)",
    }
end

------------------
---- MONITOR -----
------------------
-- Panel interno del portátil (Medion). "preferred"/"auto" funciona con
-- cualquier pantalla externa que enchufes también.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

---------------------
---- PROGRAMAS ------
---------------------
local terminal    = "kitty"
local archivos    = "thunar"
local lanzador    = "rofi -show drun"
local navegador   = "firefox-esr"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("deox-fondo")                      -- fondo del tema activo (swaybg)
    hl.exec_cmd("hypridle")                        -- bloqueo/apagado por inactividad
    hl.exec_cmd("systemctl --user start hyprpolkitagent")  -- ventanas de contraseña (sudo gráfico)
    hl.exec_cmd("nm-applet --indicator")           -- wifi en la bandeja
    hl.exec_cmd("blueman-applet")                  -- bluetooth en la bandeja
    hl.exec_cmd("wl-paste --watch cliphist store") -- historial del portapapeles
end)

-------------------------------
---- VARIABLES DE ENTORNO -----
-------------------------------
-- Los scripts deox-* viven en ~/.local/bin: que Hyprland los encuentre.
local home = os.getenv("HOME") or ""
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin:/bin"
if not path:find(home .. "/.local/bin", 1, true) then
    hl.env("PATH", home .. "/.local/bin:" .. path)
end
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "iHD")                 -- vídeo acelerado en Intel Iris Xe
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")         -- Burp Suite, Ghidra, ZAP... (Java) sin ventanas grises

-----------------------
---- ASPECTO ----------
-----------------------
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { c.accent, c.accent2 }, angle = 45 },
            inactive_border = c.inactive,
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = c.shadow,
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curvas y animaciones (suaves, sin marear).
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},      {1, 1}    } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},  {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}  } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy",   style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })

hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,     -- sin fondos anime por defecto: ponemos el nuestro
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
})

---------------
---- TECLADO / TOUCHPAD
---------------
hl.config({
    input = {
        kb_layout    = "es",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

-- Tres dedos en horizontal = cambiar de escritorio.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- ATAJOS ---------
---------------------
-- Chuleta completa: SUPER + F1  (o docs/ATAJOS.md)
local mod = "SUPER"

hl.bind(mod .. " + RETURN",      hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D",           hl.dsp.exec_cmd(lanzador))
hl.bind(mod .. " + E",           hl.dsp.exec_cmd(archivos))
hl.bind(mod .. " + B",           hl.dsp.exec_cmd(navegador))
hl.bind(mod .. " + Q",           hl.dsp.window.close())
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + L",           hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mod .. " + SHIFT + E",   hl.dsp.exec_cmd("wlogout -b 5 -p layer-shell"))
hl.bind(mod .. " + C",           hl.dsp.exec_cmd("deox-portapapeles"))
hl.bind(mod .. " + T",           hl.dsp.exec_cmd("deox-tema --menu"))
hl.bind(mod .. " + F1",          hl.dsp.exec_cmd("deox-atajos"))
hl.bind(mod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + W",   hl.dsp.exec_cmd("pkill waybar; waybar"))
hl.bind("Print",                 hl.dsp.exec_cmd("deox-captura zona"))
hl.bind("SHIFT + Print",         hl.dsp.exec_cmd("deox-captura pantalla"))

-- Mover el foco con SUPER + flechas.
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover la ventana con SUPER + SHIFT + flechas.
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Escritorios 1..10 (SUPER + número) y mandar ventana (SUPER + SHIFT + número).
for i = 1, 10 do
    local tecla = i % 10
    hl.bind(mod .. " + " .. tecla,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. tecla, hl.dsp.window.move({ workspace = i }))
end

-- Escritorio "oculto" para notas/terminal rápida.
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Rueda del ratón para pasar de escritorio; arrastrar/redimensionar con el ratón.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Teclas multimedia del portátil.
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- REGLAS DE VENTANAS --------
--------------------------------
-- Ignorar peticiones de "maximizar" de las apps (en tiling molestan).
hl.window_rule({
    name  = "suprimir-maximizar",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Arreglo para arrastrar ventanas XWayland.
hl.window_rule({
    name  = "arreglo-xwayland",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Ventanitas de ajustes: flotantes.
for _, clase in ipairs({ "pavucontrol", "blueman-manager", "nm-connection-editor", "nwg-look", "qt6ct" }) do
    hl.window_rule({
        name  = "flotar-" .. clase,
        match = { class = "^(" .. clase .. ")$" },
        float = true,
    })
end

-- No apagar la pantalla mientras ves algo a pantalla completa.
hl.window_rule({
    name  = "no-dormir-en-fullscreen",
    match = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- Desenfoque detrás de la barra, el lanzador y las notificaciones.
for _, capa in ipairs({ "waybar", "rofi", "notifications", "logout_dialog" }) do
    hl.layer_rule({
        name  = "blur-" .. capa,
        match = { namespace = "^(" .. capa .. ")$" },
        blur  = true,
        ignore_alpha = 0.2,
    })
end

--------------------------------
---- TUS AJUSTES PERSONALES ----
--------------------------------
-- ~/.config/hypr/usuario.lua se carga lo último: lo que pongas ahí gana.
pcall(require, "usuario")
