#!/usr/bin/env bash
# tests/verificar.sh — revisa el repo antes de hacer commit. No instala nada.
#   bash tests/verificar.sh
# Comprueba:
#   1. Sintaxis bash + shellcheck de todos los scripts.
#   2. JSON/JSONC válidos (waybar, fastfetch).
#   3. Temas completos y colores válidos; plantillas sin claves desconocidas.
#   4. Sintaxis Lua de hyprland.lua (luac) y, si hay Hyprland, --verify-config
#      con cada tema aplicado (en un HOME temporal).
#   5. En Kali: que todos los paquetes de packages/*.txt existen en los repos.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
FALLOS=0
bien() { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
mal()  { printf '  \033[1;31m✗\033[0m %s\n' "$*"; FALLOS=$((FALLOS + 1)); }
salta(){ printf '  \033[1;33m-\033[0m %s\n' "$*"; }
sec()  { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }

SCRIPTS=(migrar.sh scripts/*.sh migracion/*.sh tests/*.sh)
for f in dotfiles/bin/*; do head -1 "$f" | grep -q bash && SCRIPTS+=("$f"); done

sec "1 · Scripts bash"
for f in "${SCRIPTS[@]}"; do bash -n "$f" || mal "sintaxis: $f"; done
bien "bash -n en ${#SCRIPTS[@]} scripts"
if command -v shellcheck >/dev/null; then
  if LANG=C.UTF-8 shellcheck -x -S warning "${SCRIPTS[@]}"; then bien "shellcheck sin avisos"; else mal "shellcheck"; fi
else salta "shellcheck no instalado (sudo apt install shellcheck)"; fi
for f in dotfiles/bin/*; do
  [ -x "$f" ] || mal "no es ejecutable: $f"
  if head -1 "$f" | grep -q python; then
    PYTHONPYCACHEPREFIX="$(mktemp -d)" python3 -m py_compile "$f" 2>/dev/null && bien "python OK: $f" || mal "python: $f"
  fi
done

sec "2 · JSON"
for f in dotfiles/waybar/config.jsonc dotfiles/fastfetch/config.jsonc; do
  if python3 -c 'import json,re,sys;t=open(sys.argv[1]).read();json.loads(re.sub(r"^\s*//.*$","",t,flags=re.M))' "$f"; then
    bien "$f"; else mal "$f"; fi
done

sec "3 · Temas y plantillas"
CLAVES="nombre bg bg2 bg3 fg fg_dim accent accent2 ok warn err magenta wallpaper"
for t in dotfiles/temas/*.tema; do
  for k in $CLAVES; do
    v="$(sed -n "s/^$k=\"\{0,1\}\([^\"#]*\)\"\{0,1\}.*/\1/p" "$t" | head -1 | tr -d ' ')"
    [ -n "$v" ] || { mal "$t: falta $k"; continue; }
    case "$k" in nombre|wallpaper) ;; *) [[ "$v" =~ ^[0-9a-fA-F]{6}$ ]] || mal "$t: $k='$v' no es hex" ;; esac
  done
  n="$(sed -n 's/^nombre="\{0,1\}\([^"]*\)"\{0,1\}.*/\1/p' "$t")"
  [ "$n" = "$(basename "$t" .tema)" ] || mal "$t: nombre='$n' no coincide con el fichero"
done
bien "$(ls dotfiles/temas/*.tema | wc -l) temas revisados"
desconocidas="$(grep -rhoE '@@[a-z_0-9]+@@' --include='*.tpl' dotfiles | sort -u | tr -d @ | grep -vxE "$(echo "$CLAVES" | tr ' ' '|')" || true)"
[ -z "$desconocidas" ] && bien "Plantillas solo usan claves conocidas" || mal "Claves desconocidas en plantillas: $desconocidas"

sec "4 · Hyprland (Lua)"
LUAC="$(command -v luac5.4 || command -v luac5.5 || command -v luac || true)"
if [ -n "$LUAC" ]; then
  for f in dotfiles/hypr/*.lua; do "$LUAC" -p "$f" && bien "luac: $f" || mal "luac: $f"; done
else salta "luac no instalado"; fi
if command -v Hyprland >/dev/null && [ "$(id -u)" -ne 0 ]; then
  H="$(mktemp -d)"; trap 'rm -rf "$H"' EXIT
  mkdir -p "$H/.config/hypr" "$H/rt"; chmod 700 "$H/rt"
  cp dotfiles/hypr/hyprland.lua "$H/.config/hypr/"
  for t in dotfiles/temas/*.tema; do
    mkdir -p "$H/.local/share/kali-deox/plantillas/hypr"
    cp -r dotfiles/temas "$H/.local/share/kali-deox/"
    cp dotfiles/hypr/colores.lua.tpl "$H/.local/share/kali-deox/plantillas/hypr/"
    HOME="$H" XDG_CONFIG_HOME="$H/.config" bash dotfiles/bin/deox-tema "$(basename "$t" .tema)" >/dev/null
    if HOME="$H" XDG_RUNTIME_DIR="$H/rt" Hyprland --verify-config --config "$H/.config/hypr/hyprland.lua" 2>&1 | tail -1 | grep -q 'config ok'; then
      bien "Hyprland --verify-config con tema $(basename "$t" .tema)"
    else mal "Hyprland rechaza la config con tema $(basename "$t" .tema)"; fi
  done
else salta "Hyprland no instalado (o eres root): sin --verify-config"; fi

sec "5 · Paquetes"
if grep -qi '^ID=kali' /etc/os-release 2>/dev/null; then
  for l in packages/*.txt; do
    while read -r p; do
      apt-cache show "$p" >/dev/null 2>&1 || mal "$l: '$p' no existe en los repos"
    done < <(sed 's/#.*//' "$l" | tr -s '[:space:]' '\n' | sed '/^$/d')
    bien "$l"
  done
else salta "No estás en Kali: no compruebo nombres de paquetes"; fi

echo
if [ "$FALLOS" -eq 0 ]; then printf '\033[1;32mTodo correcto.\033[0m\n'; else printf '\033[1;31m%d fallo(s).\033[0m\n' "$FALLOS"; exit 1; fi
