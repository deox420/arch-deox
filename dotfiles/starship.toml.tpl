# ~/.config/starship.toml — prompt de la terminal. GENERADO por deox-tema (@@nombre@@).
# Muestra: usuario@host, carpeta, git, IP de VPN y objetivo (si hay), y si el último comando falló.
"$schema" = 'https://starship.rs/config-schema.json'
add_newline = true

format = """
[┌──](bold @@accent@@)$username[@](@@fg_dim@@)$hostname $directory$git_branch$git_status${custom.vpn}${custom.objetivo}$python
[└─](bold @@accent@@)$character"""

[username]
show_always = true
style_user = "bold @@accent2@@"
style_root = "bold @@err@@"
format = "[$user]($style)"

[hostname]
ssh_only = false
style = "bold @@accent@@"
format = "[$hostname]($style)"

[directory]
style = "bold @@fg@@"
truncation_length = 4
format = "[ $path]($style) "

[git_branch]
style = "@@magenta@@"
format = "[ $branch]($style) "

[git_status]
style = "@@warn@@"

[python]
style = "@@warn@@"
format = '[ $virtualenv]($style) '
detect_extensions = []
detect_files = []

[character]
success_symbol = "[❯](bold @@ok@@)"
error_symbol = "[✗](bold @@err@@)"

[custom.vpn]
command = "deox-vpn-ip"
when = "deox-vpn-ip"
style = "bold @@ok@@"
format = "[󰖂 $output]($style) "

[custom.objetivo]
command = "deox-objetivo"
when = "deox-objetivo"
style = "bold @@err@@"
format = "[󰓾 $output]($style) "
