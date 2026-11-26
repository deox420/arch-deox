#!/usr/bin/env bash
# 50-snapshots.sh — "volver atrás en el tiempo" si una actualización rompe algo.
# ---------------------------------------------------------------------------
# Kali es rolling: se actualiza a diario y, de vez en cuando, algo se rompe.
# Timeshift guarda fotos del SISTEMA (no de tus documentos) y permite volver.
#   - Si instalaste Kali en Btrfs  → snapshots instantáneos (modo BTRFS).
#   - Si es ext4 (lo normal)       → modo RSYNC (más lento, igual de útil).
# Para tus DATOS usa una copia externa: scripts/60-copia.sh
#   bash scripts/50-snapshots.sh
# ---------------------------------------------------------------------------
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

command -v timeshift >/dev/null || morir "Falta timeshift (está en packages/base.txt: bash scripts/10-sistema.sh)."
FS="$(findmnt -no FSTYPE /)"
info "Sistema de archivos de / : $FS"
LIBRE_GB=$(( $(df --output=avail -k / | tail -1) / 1024 / 1024 ))
echo "   Espacio libre: ${LIBRE_GB} GB"
[ "$LIBRE_GB" -lt 20 ] && aviso "Poco espacio: los snapshots rsync ocupan bastante. Deja al menos 20 GB."

modo="--rsync"; [ "$FS" = btrfs ] && modo="--btrfs"
if ask "¿Creo un snapshot ahora (modo ${modo#--})?"; then
  if sudo timeshift --create "$modo" --comments "kali-deox $(date +%F)" --tags D; then
    ok "Snapshot creado"
  else
    aviso "timeshift no pudo crear el snapshot (¿primera vez?). Ábrelo con 'sudo timeshift-gtk',"
    aviso "elige el disco y el tipo en el asistente, y vuelve a lanzarme."
  fi
fi
cat <<'TXT'

  ── CÓMO VOLVER ATRÁS ───────────────────────────────────────────
  · Con el escritorio funcionando:  sudo timeshift-gtk  → elegir → Restaurar
  · Si no arranca el escritorio: en el login pulsa Ctrl+Alt+F2, entra y:
        sudo timeshift --list
        sudo timeshift --restore
  · Programar snapshots automáticos: abre timeshift-gtk → Programación
    (recomendado: diario 3, semanal 2).
  · Consejo: crea uno ANTES de cada 'apt full-upgrade' grande:
        sudo timeshift --create --comments "antes de actualizar"
  ────────────────────────────────────────────────────────────────
TXT
