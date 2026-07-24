#!/usr/bin/env bash
# 00-post-install.sh — primeros pasos tras instalar CachyOS (base del entorno).
# ---------------------------------------------------------------------------
# Qué hace, en orden:
#   1. Actualiza el sistema entero (evita "partial upgrades", que rompen Arch/CachyOS).
#   2. Instala los drivers de vídeo Intel (portátil Medion, Iris Xe) + microcódigo.
#   3. Instala utilidades de sistema que Caelestia da por hechas o que querrás sí o sí.
#
# Es IDEMPOTENTE: si algo ya está, pacman lo salta (--needed).
# Lo lanzas TÚ en el portátil, no esta sesión:  bash scripts/00-post-install.sh
# Pedirá tu contraseña de sudo cuando toque instalar.
# ---------------------------------------------------------------------------
set -euo pipefail

# --- Ayudas ----------------------------------------------------------------
info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root. Córrelo como tu usuario; ya pediré sudo yo." >&2
  exit 1
fi

# --- 1) Actualización total -------------------------------------------------
info "1/3 · Actualizar el sistema (pacman -Syu)"
if ask "¿Actualizo TODO el sistema ahora?"; then
  sudo pacman -Syu --needed
else
  echo "   (saltado — hazlo tú antes de instalar nada más)"
fi

# --- 2) Drivers Intel (Iris Xe) --------------------------------------------
# vulkan-intel      : Vulkan para la iGPU
# intel-media-driver: aceleración de vídeo (VA-API moderno, Gen 12/Iris Xe)
# libva-utils       : trae 'vainfo' para comprobar que la aceleración va
# intel-ucode       : microcódigo del CPU (correcciones/seguridad)
info "2/3 · Drivers de vídeo Intel + microcódigo"
if ask "¿Instalo los drivers Intel (vulkan-intel, intel-media-driver, libva-utils, intel-ucode)?"; then
  sudo pacman -S --needed vulkan-intel intel-media-driver libva-utils intel-ucode
  echo "   Comprueba luego con:  vainfo   (debe listar perfiles H264/HEVC)"
fi

# --- 3) Utilidades de sistema ----------------------------------------------
# Complementos que NO cubre 'caelestia install' o que querrás igualmente.
# (La lista completa y comentada está en packages/pkglist-native.txt.)
info "3/3 · Utilidades base del sistema"
if ask "¿Instalo las utilidades de packages/pkglist-native.txt?"; then
  DIR="$(cd "$(dirname "$0")/.." && pwd)"
  sudo pacman -S --needed - < "$DIR/packages/pkglist-native.txt"
fi

info "Listo. Siguiente paso:  bash scripts/10-caelestia.sh"
