#!/usr/bin/env bash
# bootstrap.sh — RECONSTRUCCIÓN EXPRÉS: monta todo el entorno de un tirón.
# ---------------------------------------------------------------------------
# Tras una instalación limpia de CachyOS (o para rehacer el entorno), esto
# encadena los pasos en orden y te va preguntando. Objetivo: dejar el portátil
# listo con el menor número de comandos.
#
#     git clone https://github.com/deox420/arch-deox.git
#     cd arch-deox
#     bash scripts/bootstrap.sh
#
# Es interactivo e idempotente: puedes relanzarlo si algo se quedó a medias.
# ---------------------------------------------------------------------------
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

titulo() { printf '\n\033[1;35m########  %s  ########\033[0m\n' "$*"; }
ask()    { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root. Córrelo como tu usuario (ya pediré sudo donde toque)." >&2
  exit 1
fi

cat <<'EOF'
=============================================================
  arch-deox · reconstrucción exprés (CachyOS + Caelestia)
  Voy a ejecutar, en orden y preguntándote en cada bloque:
    1) scripts/00-post-install.sh   (sistema + drivers Intel)
    2) scripts/10-caelestia.sh      (helper AUR + caelestia-cli)
       -> luego TÚ lanzas:  caelestia install
    3) scripts/20-login-manager.sh  (greetd + tuigreet)
    4) scripts/30-extras.sh         (AUR / firewall / bluetooth)
    5) scripts/40-snapshots.sh      (snapshots + rollback)
  Puedes decir N a cualquier bloque y saltarlo.
=============================================================
EOF
ask "¿Empezamos?" || { echo "Cancelado."; exit 0; }

titulo "PASO 1 · sistema + drivers"
ask "¿Ejecuto 00-post-install.sh?" && bash scripts/00-post-install.sh

titulo "PASO 2 · Caelestia"
ask "¿Ejecuto 10-caelestia.sh?" && bash scripts/10-caelestia.sh
echo
echo "  >> AHORA, a mano y en interactivo:   caelestia install"
echo "     (elige componentes: hypr, fish, foot, fonts, gtk, qt, auth, network,"
echo "      bluetooth, pipewire, clipboard, tools...)"
read -rp "  Pulsa Enter cuando 'caelestia install' haya terminado (o para saltar)... " _

titulo "PASO 3 · login"
ask "¿Ejecuto 20-login-manager.sh?" && bash scripts/20-login-manager.sh

titulo "PASO 4 · extras"
ask "¿Ejecuto 30-extras.sh?" && bash scripts/30-extras.sh

titulo "PASO 5 · snapshots / rollback"
ask "¿Ejecuto 40-snapshots.sh?" && bash scripts/40-snapshots.sh

titulo "PASO 6 · tus overrides"
echo "  Copia tus ajustes personales siguiendo overrides/README.md"
echo "  (monitor eDP-1, teclado ES, Intel). Luego:  hyprctl reload"

echo
echo "== Reconstrucción terminada. Revisa y reinicia cuando quieras (reboot). =="
