#!/usr/bin/env bash
# 30-extras.sh — extras opcionales (apps personales + AUR + servicios).
# ---------------------------------------------------------------------------
# Todo aquí es OPCIONAL. Instala lo que quieras y salta el resto.
#   1. Paquetes AUR de packages/pkglist-aur.txt (caelestia-cli va aquí también).
#   2. Firewall ufw (denegar entrante / permitir saliente) + activarlo.
#   3. Servicios útiles (bluetooth) si los quieres al arranque.
#
# Lo lanzas TÚ en el portátil:  bash scripts/30-extras.sh
# ---------------------------------------------------------------------------
set -euo pipefail

info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root; el helper AUR debe correr como tu usuario." >&2
  exit 1
fi

DIR="$(cd "$(dirname "$0")/.." && pwd)"

# --- 1) AUR ----------------------------------------------------------------
info "1/3 · Paquetes AUR (packages/pkglist-aur.txt)"
HELPER=""
for h in shelly paru yay; do command -v "$h" >/dev/null 2>&1 && { HELPER="$h"; break; }; done
if [ -n "$HELPER" ] && ask "¿Instalo la lista AUR con $HELPER?"; then
  "$HELPER" -S --needed - < "$DIR/packages/pkglist-aur.txt"
elif [ -z "$HELPER" ]; then
  echo "   (no hay helper AUR; sáltatelo o instala paru/shelly primero)"
fi

# --- 2) Firewall -----------------------------------------------------------
info "2/3 · Firewall ufw (denegar entrante / permitir saliente)"
if ask "¿Configuro y activo ufw?"; then
  sudo pacman -S --needed ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
  sudo systemctl enable ufw.service
  sudo ufw status verbose
fi

# --- 3) Bluetooth ----------------------------------------------------------
info "3/3 · Activar Bluetooth al arranque"
if ask "¿Activo bluetooth.service?"; then
  sudo systemctl enable --now bluetooth.service
fi

info "Extras hechos."
