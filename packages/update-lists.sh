#!/usr/bin/env bash
# update-lists.sh — AUDITORÍA de paquetes (no destructiva).
# ---------------------------------------------------------------------------
# Antes este script REGENERABA las listas con 'pacman -Qqe'. Ya no: en el modelo
# CachyOS + Caelestia el grueso del escritorio lo instala 'caelestia install',
# así que pkglist-native.txt / pkglist-aur.txt son listas CURADAS a mano (solo
# complementos). Regenerarlas mecánicamente las llenaría de ruido.
#
# En su lugar, esto solo COMPARA lo que tienes instalado con lo que hay en las
# listas y te avisa de las diferencias, para que decidas tú qué añadir/quitar.
# No escribe nada. Uso:  ./update-lists.sh
# ---------------------------------------------------------------------------
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

lista() { grep -vE '^\s*#|^\s*$' "$1" 2>/dev/null | sort -u; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Explícitos nativos (repos) y foráneos (AUR), sin paquetes -debug.
pacman -Qqen | sort -u > "$TMP/nat_sys"
pacman -Qqem | grep -v -- '-debug$' | sort -u > "$TMP/aur_sys"
lista "$DIR/pkglist-native.txt" > "$TMP/nat_list"
lista "$DIR/pkglist-aur.txt"    > "$TMP/aur_list"

sec() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }

sec "En la lista NATIVA pero NO instalados"
comm -23 "$TMP/nat_list" "$TMP/nat_sys" | sed 's/^/  /' || true

sec "Instalados (nativos explícitos) que NO están en la lista"
echo "  (revísalos: quizá alguno merezca entrar en pkglist-native.txt)"
comm -13 "$TMP/nat_list" "$TMP/nat_sys" | sed 's/^/  /' || true

sec "En la lista AUR pero NO instalados"
comm -23 "$TMP/aur_list" "$TMP/aur_sys" | sed 's/^/  /' || true

sec "Instalados (AUR) que NO están en la lista"
comm -13 "$TMP/aur_list" "$TMP/aur_sys" | sed 's/^/  /' || true

echo
echo "Nada se ha modificado. Edita las listas a mano según lo de arriba."
