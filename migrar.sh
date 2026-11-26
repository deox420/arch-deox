#!/usr/bin/env bash
# migrar.sh — PUNTO DE ENTRADA ÚNICO. Detecta dónde estás y hace lo que toca:
#   · En CachyOS/Arch → prepara la migración (copia + ISO verificada + USB).
#   · En Kali         → monta el escritorio kali-deox y las herramientas.
#     bash migrar.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
. /etc/os-release 2>/dev/null || true
case "${ID:-}" in
  kali)
    echo "Estás en Kali → montaje de kali-deox."
    exec bash "$DIR/scripts/bootstrap.sh" ;;
  arch|cachyos|endeavouros|manjaro)
    echo "Estás en ${PRETTY_NAME:-Arch} → preparar la migración a Kali."
    exec bash "$DIR/migracion/migrar-desde-cachyos.sh" "$@" ;;
  *)
    if [[ " ${ID_LIKE:-} " == *" arch "* ]]; then exec bash "$DIR/migracion/migrar-desde-cachyos.sh" "$@"; fi
    echo "Sistema '${PRETTY_NAME:-desconocido}'. Opciones:"
    echo "  bash migracion/migrar-desde-cachyos.sh   (preparar copia + USB de Kali)"
    echo "  bash scripts/bootstrap.sh                (ya en Kali)"
    exit 1 ;;
esac
