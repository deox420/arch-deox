#!/usr/bin/env bash
# ==========================================================================
# build.sh — construye la ISO live de arch-deox.
#
# Estrategia (reproducible): NO versionamos el boilerplate de archiso. Partimos
# del perfil OFICIAL 'releng' (el de tu archiso instalado) y le superponemos
# nuestras capas:
#   - packages.extra.x86_64  -> se añaden a packages.x86_64 del perfil
#   - airootfs/              -> se copia sobre el airootfs del perfil
#   - profiledef.sh          -> se ajusta iso_name/label y permisos de scripts
#
# Salida: iso/out/*.iso   (ambos dirs están en .gitignore)
#
# Uso:
#   ./build.sh --dry-run    # muestra los pasos sin construir
#   ./build.sh              # construye (mkarchiso usa sudo: pedirá confirmación)
#
# Requiere: paquete 'archiso'.  Ejecuta como usuario normal (sudo solo en mkarchiso).
# ==========================================================================

set -Eeuo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELENG="/usr/share/archiso/configs/releng"
PROFILE="${DIR}/work/profile"     # perfil ensamblado (gitignored)
WORK="${DIR}/work/tmp"            # workdir de mkarchiso (gitignored)
OUT="${DIR}/out"                 # ISOs resultantes (gitignored)

ISO_NAME="arch-deox"
ISO_LABEL="ARCHDEOX_$(printf '%s' "$(date +%Y%m 2>/dev/null || echo 000000)")"
ISO_PUBLISHER="deox420 <https://github.com/deox420/arch-deox>"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

info() { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }
die()  { printf '[x] %s\n' "$*" >&2; exit 1; }
run()  { if [[ $DRY_RUN -eq 1 ]]; then printf '[dry-run] %s\n' "$*"; else eval "$*"; fi; }

# --- Comprobaciones --------------------------------------------------------
[[ -f /etc/arch-release ]] || die "La ISO se construye desde Arch (necesita archiso)."
command -v mkarchiso &>/dev/null || die "Falta 'archiso'. Instálalo: sudo pacman -S archiso"
[[ -d "$RELENG" ]] || die "No encuentro el perfil releng en $RELENG"

# --- 1. Ensamblar perfil a partir de releng -------------------------------
info "Copiando perfil base releng -> $PROFILE"
run "rm -rf '$PROFILE'"
run "mkdir -p '$(dirname "$PROFILE")'"
run "cp -r '$RELENG' '$PROFILE'"

# --- 2. Añadir nuestros paquetes ------------------------------------------
info "Añadiendo paquetes de packages.extra.x86_64"
if [[ $DRY_RUN -eq 0 ]]; then
    {
        echo ""
        echo "# --- arch-deox extra ---"
        grep -vE '^\s*(#|$)' "${DIR}/packages.extra.x86_64"
    } >> "${PROFILE}/packages.x86_64"
fi

# --- 3. Superponer airootfs -----------------------------------------------
if [[ -d "${DIR}/airootfs" ]]; then
    info "Superponiendo airootfs/"
    run "cp -r '${DIR}/airootfs/.' '${PROFILE}/airootfs/'"
fi

# --- 4. Ajustar profiledef.sh (nombre, label, publisher, permisos) --------
info "Personalizando profiledef.sh"
if [[ $DRY_RUN -eq 0 ]]; then
    pd="${PROFILE}/profiledef.sh"
    sed -i \
        -e "s|^iso_name=.*|iso_name=\"${ISO_NAME}\"|" \
        -e "s|^iso_label=.*|iso_label=\"${ISO_LABEL}\"|" \
        -e "s|^iso_publisher=.*|iso_publisher=\"${ISO_PUBLISHER}\"|" \
        "$pd"
    # Dar permiso de ejecución a nuestros scripts del airootfs.
    if ! grep -q '/usr/local/bin/arch-deox-install' "$pd"; then
        sed -i '/^file_permissions=(/a\  ["/usr/local/bin/arch-deox-install"]="0:0:755"' "$pd"
    fi
fi

# --- 5. Construir ----------------------------------------------------------
warn "mkarchiso usa sudo y puede tardar/descargar bastante."
if [[ $DRY_RUN -eq 1 ]]; then
    printf '[dry-run] sudo mkarchiso -v -w %s -o %s %s\n' "$WORK" "$OUT" "$PROFILE"
    ok "Dry-run completado. Nada construido."
    exit 0
fi

read -rp "Construir la ISO ahora? [y/N] " ans
[[ "${ans,,}" == "y" ]] || die "Cancelado."

mkdir -p "$WORK" "$OUT"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
ok "ISO generada en: $OUT"
echo "Para el USB portátil: copia el .iso a tu unidad Ventoy (persistencia: ver iso/README.md)."
