# CLAUDE.md

> Archivo de instrucciones para Claude Code. Se carga automáticamente al abrir el repo.

## Qué es este proyecto

Repositorio de configuración reproducible para Arch Linux puro. Objetivo: instalar mi
sistema completo (base + dotfiles + ricing + herramientas de pentesting) en cualquier
dispositivo, ya sea desde instalación limpia o desde una ISO/USB portátil.

- Usuario GitHub: deox420
- Repo: https://github.com/deox420/arch-deox
- Base: Arch Linux puro (NO una derivada). BlackArch se añade encima por capas.
- Dotfiles: chezmoi (fuente en home/, con .chezmoiroot).
- Ricing: Hyprland + Waybar + Rofi + Mako + Catppuccin/pywal.
- Pentesting: repo BlackArch vía strap.sh, instalado POR CATEGORÍAS (grupos blackarch-*).
- Medio portátil: ISO custom con archiso (perfil releng) + persistencia vía Ventoy.

## Estructura del repo

arch-deox/
├── README.md
├── CLAUDE.md
├── install.sh                # bootstrap: helper AUR + pkglists + chezmoi + servicios
├── archinstall/
│   ├── user_configuration.json
│   └── user_disk_layout.json
├── packages/
│   ├── pkglist-native.txt    # pacman -Qqen
│   └── pkglist-aur.txt       # pacman -Qqem
├── ansible/                  # opcional, provisioning idempotente
├── home/                     # fuente chezmoi (.chezmoiroot apunta aquí)
│   └── dot_config/{hypr,waybar,rofi,mako,kitty}/
├── iso/                      # perfil archiso
└── pentest/                  # listas de grupos BlackArch + ficheros de menú XDG

## Convenciones y reglas

- Usa gh (GitHub CLI) para operaciones de GitHub.
- Regenera packages/pkglist-*.txt cuando cambien paquetes.
- Paquetes: nativos con `pacman -Qqen`, AUR con `pacman -Qqem`. Helper: paru.
- Dotfiles en home/ con prefijos chezmoi (dot_, .tmpl para plantillas).
- Bootstrap en máquina nueva: chezmoi init --apply deox420
- archinstall remoto: archinstall --config https://raw.githubusercontent.com/deox420/arch-deox/main/archinstall/user_configuration.json

## Reglas de seguridad (NO NEGOCIABLES)

- NUNCA hagas commit de secretos (claves SSH/GPG, tokens, credenciales, user_credentials.json).
- Secretos cifrados con age vía chezmoi (chezmoi add --encrypt), nunca en claro.
- Mantén un .gitignore con allowlist; ignora *.key, *credentials*, history.jsonl, cache/.
- Pide confirmación antes de: git push, rm, sudo, pacman -S, curl|sh, y antes de reconstruir la ISO.
- Antes de cualquier chezmoi apply, muestra primero chezmoi diff.
- Herramientas de pentesting solo para uso autorizado.

## Tareas típicas que pediré

1. Generar/editar install.sh de bootstrap.
2. Crear el perfil archiso en iso/ (releng + mis paquetes + airootfs).
3. Escribir ficheros de menú XDG en pentest/ que clasifican herramientas estilo Kali.
4. Mantener sincronizadas listas de paquetes y README.
5. Refactorizar configs de Hyprland/Waybar/Rofi.

## Lo que NO debes asumir

- No inventes versiones de paquetes ni rutas; verifica con pacman/el sistema.
- No cambies la base de Arch puro a una derivada.
- No expongas ningún servicio a internet sin avisarme del riesgo de seguridad primero.
