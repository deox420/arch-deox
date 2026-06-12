#!/usr/bin/env bash
# update-lists.sh — regenera las listas de paquetes de arch-deox SEPARADAS POR ORIGEN.
#
# Por qué: una sola lista con `pacman -Qqe` mezcla paquetes de repos oficiales,
# de BlackArch y de AUR. En una máquina recién instalada eso ROMPE el paso
# "pacman -S < lista" (BlackArch aún no está habilitado y los de AUR no existen
# en pacman). Separadas, cada lista se instala en su momento.
#
# Uso:  ./update-lists.sh   (desde cualquier sitio; escribe junto a este script)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
FECHA="$(date +%F)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Explícitos nativos (instalados desde algún repo) y foráneos (AUR/manuales).
pacman -Qqen | sort > "$TMP/explicit"
pacman -Qqem | grep -v -- '-debug$' | sort > "$TMP/aur"   # sin paquetes -debug

# Qué ofrece cada grupo de repos (multilib puede no estar habilitado).
pacman -Slq core extra multilib 2>/dev/null | sort -u > "$TMP/oficial" || true
pacman -Slq blackarch 2>/dev/null | sort -u > "$TMP/blackarch" || : > "$TMP/blackarch"

# Reparto: oficial / blackarch / desconocido (se avisa y se deja en la nativa).
comm -12 "$TMP/explicit" "$TMP/oficial"   > "$TMP/nativos"
comm -23 "$TMP/explicit" "$TMP/oficial"   > "$TMP/resto"
comm -12 "$TMP/resto"    "$TMP/blackarch" > "$TMP/black"
comm -23 "$TMP/resto"    "$TMP/blackarch" > "$TMP/desconocidos"

if [ -s "$TMP/desconocidos" ]; then
  echo "[!] Paquetes explícitos que no encuentro en ningún repo (los dejo en la nativa):" >&2
  sed 's/^/      /' "$TMP/desconocidos" >&2
  cat "$TMP/desconocidos" >> "$TMP/nativos"; sort -o "$TMP/nativos" "$TMP/nativos"
fi

{ echo "# pkglist-native.txt — explícitos de repos OFICIALES (pacman -Qqen, sin BlackArch)"
  echo "# Regenerado: $FECHA con update-lists.sh · reinstalar: sudo pacman -S --needed - < pkglist-native.txt"
  cat "$TMP/nativos"; } > "$DIR/pkglist-native.txt"

{ echo "# pkglist-blackarch.txt — explícitos del repo BLACKARCH (instalar DESPUÉS de strap.sh)"
  echo "# Regenerado: $FECHA con update-lists.sh · reinstalar: sudo pacman -S --needed - < pkglist-blackarch.txt"
  cat "$TMP/black"; } > "$DIR/pkglist-blackarch.txt"

{ echo "# pkglist-aur.txt — foráneos/AUR (pacman -Qqem, sin -debug)"
  echo "# Regenerado: $FECHA con update-lists.sh · reinstalar: paru -S --needed - < pkglist-aur.txt"
  cat "$TMP/aur"; } > "$DIR/pkglist-aur.txt"

echo "OK · nativos: $(grep -vc '^#' "$DIR/pkglist-native.txt") · blackarch: $(grep -vc '^#' "$DIR/pkglist-blackarch.txt") · aur: $(grep -vc '^#' "$DIR/pkglist-aur.txt")"
