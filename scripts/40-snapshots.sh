#!/usr/bin/env bash
# 40-snapshots.sh — snapshots del sistema + poder VOLVER ATRÁS en minutos.
# ---------------------------------------------------------------------------
# La idea: si una actualización rompe el escritorio, reinicias, eliges un
# snapshot que funcionaba y listo. En CachyOS con Btrfs esto suele venir YA
# montado; este script lo COMPRUEBA y completa lo que falte.
#
#   - Btrfs (por defecto en CachyOS): snapper + snap-pac (snapshot automático
#     antes/después de cada pacman) + limine-snapper-sync (mételos en el menú
#     de arranque) + btrfs-assistant (GUI para gestionarlos).
#   - Si NO es Btrfs (p.ej. ext4): se ofrece timeshift como alternativa fácil.
#
# Lo lanzas TÚ en el portátil:  bash scripts/40-snapshots.sh
# ---------------------------------------------------------------------------
set -euo pipefail

info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '   \033[1;33m!\033[0m %s\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root; ya pediré sudo donde haga falta." >&2
  exit 1
fi

FSTYPE="$(findmnt -no FSTYPE / || true)"
info "Sistema de archivos de / → ${FSTYPE:-desconocido}"

# --- Rama Btrfs (lo normal en CachyOS) -------------------------------------
if [ "$FSTYPE" = "btrfs" ]; then
  info "1/3 · Comprobar herramientas de snapshots"
  faltan=()
  for p in snapper snap-pac btrfs-assistant; do
    if pacman -Qq "$p" >/dev/null 2>&1; then ok "$p instalado"; else warn "$p falta"; faltan+=("$p"); fi
  done
  # El sincronizador depende del gestor de arranque de CachyOS.
  if [ -d /boot/EFI/limine ] || pacman -Qq limine >/dev/null 2>&1; then
    if pacman -Qq limine-snapper-sync >/dev/null 2>&1; then ok "limine-snapper-sync instalado"
    else warn "limine-snapper-sync falta"; faltan+=("limine-snapper-sync"); fi
  else
    if pacman -Qq grub-btrfs >/dev/null 2>&1; then ok "grub-btrfs instalado"
    else warn "grub-btrfs falta (para menú de snapshots en GRUB)"; faltan+=("grub-btrfs"); fi
  fi

  if [ "${#faltan[@]}" -gt 0 ] && ask "¿Instalo lo que falta (${faltan[*]})?"; then
    sudo pacman -S --needed "${faltan[@]}"
  fi

  info "2/3 · Config de snapper para / (crea la configuración si no existe)"
  if sudo snapper -c root get-config >/dev/null 2>&1; then
    ok "snapper ya tiene config 'root'"
  elif ask "¿Creo la configuración de snapper para /?"; then
    sudo snapper -c root create-config /
  fi

  info "3/3 · Activar limpieza/temporizado automático de snapshots"
  if ask "¿Activo los timers de snapper (timeline + cleanup)?"; then
    sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
    # snap-pac necesita el bootloader-sync activo para reflejarlos en el menú.
    systemctl list-unit-files | grep -q limine-snapper-sync && \
      sudo systemctl enable --now limine-snapper-sync.service 2>/dev/null || true
  fi

  cat <<'EOF'

  ── CÓMO VOLVER ATRÁS si una actualización rompe algo ──────────────
  1. Reinicia.
  2. En el menú de arranque (Limine/GRUB) elige "Snapshots" y un estado
     que funcionara (los de "pre" antes de la última actualización).
  3. Ya dentro del escritorio que funciona, abre una terminal y ejecuta:
         sudo snapper rollback
     Reinicia otra vez: ese estado bueno pasa a ser el definitivo.
  · Gestión visual de snapshots:  btrfs-assistant
  · Listar por consola:           sudo snapper list
  ───────────────────────────────────────────────────────────────────
EOF

# --- Rama NO Btrfs (ext4, etc.) --------------------------------------------
else
  warn "/ no es Btrfs: no hay snapshots nativos. Alternativa fácil: timeshift."
  if ask "¿Instalo y preparo timeshift (modo rsync)?"; then
    HELPER=""; for h in shelly paru yay; do command -v "$h" >/dev/null 2>&1 && { HELPER="$h"; break; }; done
    if pacman -Si timeshift >/dev/null 2>&1; then sudo pacman -S --needed timeshift
    elif [ -n "$HELPER" ]; then "$HELPER" -S --needed timeshift
    else warn "Instala timeshift a mano (repos o AUR) y vuelve a lanzarme."; fi
    echo "   Abre 'timeshift-gtk' para crear el primer snapshot y programarlos."
    echo "   Volver atrás: timeshift --restore (o desde la GUI)."
  fi
fi

info "Recuerda: los snapshots viven en el MISMO disco. Para un fallo de disco"
info "necesitas COPIA EXTERNA de tus datos → scripts/50-backup.sh"
