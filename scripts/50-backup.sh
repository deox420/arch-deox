#!/usr/bin/env bash
# 50-backup.sh — copia de seguridad de tus DATOS personales a un disco externo.
# ---------------------------------------------------------------------------
# Los snapshots (40-snapshots.sh) te salvan de una actualización rota, pero
# viven en el MISMO disco: si el SSD muere, mueren con él. Esto copia tus datos
# personales a otra ubicación (disco USB, otra partición, carpeta de red...).
#
# El SISTEMA y el escritorio NO se respaldan aquí: se reconstruyen con
# bootstrap.sh + caelestia. Aquí van solo tus COSAS (documentos, fotos, etc.).
#
# Uso:
#     bash scripts/50-backup.sh /ruta/al/destino          # respaldar
#     bash scripts/50-backup.sh --restore /ruta/al/backup # restaurar a ~
# ---------------------------------------------------------------------------
set -euo pipefail

info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

command -v rsync >/dev/null || { echo "Falta rsync:  sudo pacman -S rsync" >&2; exit 1; }

# Qué se respalda (edita a tu gusto). Rutas relativas a $HOME.
INCLUImos=(
  Documentos Documents
  Imágenes Pictures
  Descargas Downloads
  Vídeos Videos
  Música Music
  .ssh                       # claves (¡cuídalas!)
  .config/caelestia          # ajustes propios de Caelestia si los tocaste
  .local/share/wallpapers    # tus fondos
)

MODE="backup"; DEST=""
if [ "${1:-}" = "--restore" ]; then MODE="restore"; DEST="${2:-}"; else DEST="${1:-}"; fi
[ -n "$DEST" ] || { echo "Falta la ruta. Ver cabecera del script." >&2; exit 1; }

if [ "$MODE" = "backup" ]; then
  info "Respaldar datos personales → $DEST"
  mkdir -p "$DEST"
  for d in "${INCLUImos[@]}"; do
    [ -e "$HOME/$d" ] || continue
    echo "  · $d"
    rsync -aH --delete --info=stats1 "$HOME/$d" "$DEST/"
  done
  echo
  echo "Hecho. Guarda también este repo (o su URL) para reconstruir el sistema."
else
  info "RESTAURAR desde $DEST → $HOME"
  echo "  Esto SOBREESCRIBE archivos en tu home con los del backup."
  ask "¿Seguro que quieres restaurar?" || { echo "Cancelado."; exit 0; }
  rsync -aH --info=stats1 "$DEST"/ "$HOME"/
  echo "Restaurado."
fi
