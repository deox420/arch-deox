#!/usr/bin/env bash
# 10-caelestia.sh — instala el shell Caelestia (Quickshell sobre Hyprland).
# ---------------------------------------------------------------------------
# Caelestia se instala con SU PROPIO gestor (caelestia-cli). El flujo oficial es:
#     <helper-AUR> -S caelestia-cli
#     caelestia install
# 'caelestia install' lee su manifest y te deja elegir componentes (hypr, fish,
# foot, fastfetch, btop, thunar, gtk/qt theme, etc.) y copia sus dotfiles.
#
# Nota CachyOS 2026: el helper AUR por defecto pasó de 'paru' a 'shelly'. Este
# script detecta cuál tienes; si no hay ninguno, te ofrece compilar 'paru'.
#
# Lo lanzas TÚ en el portátil:  bash scripts/10-caelestia.sh
# ---------------------------------------------------------------------------
set -euo pipefail

info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root; el helper AUR debe correr como tu usuario." >&2
  exit 1
fi

# --- 1) Detectar / instalar un helper AUR ----------------------------------
info "1/3 · Helper AUR"
HELPER=""
for h in shelly paru yay; do
  if command -v "$h" >/dev/null 2>&1; then HELPER="$h"; break; fi
done

if [ -z "$HELPER" ]; then
  echo "   No encuentro shelly/paru/yay."
  if ask "¿Compilo 'paru' desde AUR (necesita base-devel y git)?"; then
    sudo pacman -S --needed --noconfirm base-devel git
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    ( cd "$tmp/paru" && makepkg -si )
    rm -rf "$tmp"
    HELPER="paru"
  else
    echo "   Sin helper AUR no puedo seguir. Instala shelly o paru y vuelve a lanzarme." >&2
    exit 1
  fi
fi
echo "   Usando helper AUR:  $HELPER"

# --- 2) Instalar caelestia-cli ---------------------------------------------
# quickshell-git es dependencia; el helper lo resolverá solo.
info "2/3 · Instalar caelestia-cli (arrastra quickshell y dependencias)"
if ask "¿Instalo caelestia-cli con $HELPER?"; then
  "$HELPER" -S --needed caelestia-cli
else
  echo "   (saltado)"; exit 0
fi

# --- 3) caelestia install ---------------------------------------------------
# Esto NO lo automatizo: 'caelestia install' es interactivo (eliges componentes).
# Lo lanzas tú a mano para ver y decidir cada paso.
info "3/3 · Desplegar dotfiles de Caelestia"
echo "   Ahora ejecuta EN INTERACTIVO (para elegir componentes):"
echo
echo "       caelestia install"
echo
echo "   Recomendado dejar activados al menos: hypr, fish, foot, fonts, gtk, qt,"
echo "   auth, network, bluetooth, pipewire, clipboard, tools."
echo
echo "   Cuando termine:  bash scripts/20-login-manager.sh"
