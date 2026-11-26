#!/usr/bin/env bash
# 60-copia.sh — copia y restauración de tus DATOS (no del sistema).
# ---------------------------------------------------------------------------
#   bash scripts/60-copia.sh --restaurar /ruta/kali-deox-migracion
#        Restaura la copia hecha en CachyOS por migracion/migrar-desde-cachyos.sh
#        (o una copia hecha con este mismo script). Verifica la integridad antes.
#   bash scripts/60-copia.sh /ruta/al/disco
#        Hace una copia NUEVA de tus datos de Kali en /ruta/al/disco/kali-deox-copia
#        (mismo formato: se restaura con --restaurar).
# El sistema y el escritorio no se copian: se reconstruyen con bootstrap.sh.
# ---------------------------------------------------------------------------
source "$(dirname "$0")/lib.sh"
no_root

TIPOS=(DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES VIDEOS TEMPLATES PUBLICSHARE)
EXTRAS=(cajas Proyectos Notas)

dir_tipo() {  # carpeta real de un tipo XDG; vacío si no hay
  local d; d="$(xdg-user-dir "$1" 2>/dev/null || true)"
  [ -n "$d" ] && [ "$d" != "$HOME" ] && echo "$d"
}

hacer_copia() {
  local base="${1%/}"
  [ -d "$base" ] || morir "No existe $base (¿disco montado?)."
  local D="$base/kali-deox-copia"
  mkdir -p "$D"/{datos,info}
  info "Copiando a $D"
  local t s
  for t in "${TIPOS[@]}"; do
    s="$(dir_tipo "$t")"; [ -n "$s" ] && [ -d "$s" ] || continue
    echo "   · $t ($s)"
    rsync -aH --delete --info=stats1 "$s"/ "$D/datos/$t"/
  done
  for t in "${EXTRAS[@]}"; do
    [ -d "$HOME/$t" ] || continue
    echo "   · ~/$t"
    mkdir -p "$D/datos/EXTRA/$t"
    rsync -aH --delete --info=stats1 "$HOME/$t"/ "$D/datos/EXTRA/$t"/
  done
  [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$D/info/gitconfig"
  if [ -d "$HOME/.ssh" ] && ask "¿Incluyo tus claves SSH (cifradas con contraseña)?"; then
    tar -C "$HOME" -cf - .ssh | gpg --symmetric --cipher-algo AES256 -o "$D/secretos.tar.gpg.nuevo" \
      && mv "$D/secretos.tar.gpg.nuevo" "$D/secretos.tar.gpg"
  fi
  info "Calculando sumas de verificación…"
  ( cd "$D" && find datos info -type f -print0 | sort -z | xargs -0 -r sha256sum > MANIFIESTO.sha256 \
    && { [ ! -f secretos.tar.gpg ] || sha256sum secretos.tar.gpg >> MANIFIESTO.sha256; } )
  date -Iseconds > "$D/COPIA-COMPLETA"; sync
  ok "Copia lista: $D"
}

restaurar() {
  local D="${1%/}"
  [ -f "$D/COPIA-COMPLETA" ] || morir "$D no parece una copia completa (falta COPIA-COMPLETA)."
  titulo "Restaurar copia del $(cat "$D/COPIA-COMPLETA")"

  info "1/4 · Comprobar integridad"
  if [ -f "$D/MANIFIESTO.sha256" ] && ask "¿Verifico la copia antes (recomendado; puede tardar)?"; then
    ( cd "$D" && sha256sum -c --quiet MANIFIESTO.sha256 ) || morir "Hay ficheros dañados en la copia. Revisa el disco antes de seguir."
    ok "Copia íntegra"
  fi

  info "2/4 · Tus carpetas personales (no borra nada de lo que ya tengas)"
  xdg-user-dirs-update 2>/dev/null || true
  local t dst
  for t in "${TIPOS[@]}"; do
    [ -d "$D/datos/$t" ] || continue
    dst="$(dir_tipo "$t")"; [ -n "$dst" ] || dst="$HOME/$t"
    mkdir -p "$dst"
    echo "   · $t → ${dst/#$HOME/\~}"
    rsync -aH --info=stats1 "$D/datos/$t"/ "$dst"/
  done
  if [ -d "$D/datos/EXTRA" ]; then
    for t in "$D"/datos/EXTRA/*/; do
      t="$(basename "$t")"; echo "   · ~/$t"
      rsync -aH --info=stats1 "$D/datos/EXTRA/$t"/ "$HOME/$t"/
    done
  fi

  info "3/4 · Git y configuración"
  if [ -f "$D/info/gitconfig" ]; then
    if [ -f "$HOME/.gitconfig" ] && ! cmp -s "$D/info/gitconfig" "$HOME/.gitconfig"; then
      aviso "Ya tienes ~/.gitconfig; dejo el antiguo en ~/.gitconfig.cachyos para que compares."
      cp "$D/info/gitconfig" "$HOME/.gitconfig.cachyos"
    else
      cp "$D/info/gitconfig" "$HOME/.gitconfig"; ok "~/.gitconfig restaurado"
    fi
  fi
  if [ -d "$D/info/dotfiles-viejos" ]; then
    mkdir -p "$HOME/kali-deox-restaurado"
    cp -r "$D/info/dotfiles-viejos" "$HOME/kali-deox-restaurado/"
    ok "Tus .bashrc/.zshrc/fish antiguos: ~/kali-deox-restaurado/dotfiles-viejos (para copiar alias a mano)"
  fi
  [ -f "$D/info/paquetes-cachyos.txt" ] && cp "$D/info/paquetes-cachyos.txt" "$HOME/kali-deox-restaurado/" 2>/dev/null \
    && ok "Lista de programas que tenías: ~/kali-deox-restaurado/paquetes-cachyos.txt"

  info "4/4 · Datos sensibles cifrados (SSH, GPG, wifi, Firefox)"
  if [ -f "$D/secretos.tar.gpg" ] && ask "¿Descifro y restauro los datos sensibles (te pedirá la contraseña)?"; then
    local tmp; tmp="$(mktemp -d)"; chmod 700 "$tmp"
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN
    gpg -d -o "$tmp/secretos.tar" "$D/secretos.tar.gpg" || morir "No se pudo descifrar (¿contraseña?)."
    tar -C "$tmp" -xf "$tmp/secretos.tar"
    if [ -f "$tmp/home-secretos.tar" ]; then
      for x in .ssh .gnupg; do
        if tar -tf "$tmp/home-secretos.tar" "$x" >/dev/null 2>&1 && [ -e "$HOME/$x" ]; then
          mv "$HOME/$x" "$HOME/$x.antes-de-restaurar.$(date +%s)"
        fi
      done
      tar -C "$HOME" -xf "$tmp/home-secretos.tar"
      [ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh" && find "$HOME/.ssh" -type f -exec chmod 600 {} + \
        && find "$HOME/.ssh" -type f -name '*.pub' -exec chmod 644 {} + && ok "Claves SSH restauradas (permisos 600)"
      if tar -tf "$tmp/home-secretos.tar" .gnupg >/dev/null 2>&1; then
        chmod 700 "$HOME/.gnupg" && ok "Claves GPG restauradas"
      fi
    fi
    if [ -f "$tmp/wifi.tar" ] && ask "¿Restauro tus redes wifi (sudo)?"; then
      sudo tar -C /etc/NetworkManager -xf "$tmp/wifi.tar" --no-same-owner
      sudo chown -R root:root /etc/NetworkManager/system-connections
      sudo chmod 600 /etc/NetworkManager/system-connections/*
      sudo nmcli connection reload && ok "Redes wifi restauradas"
    fi
    if [ -f "$tmp/firefox.tar" ]; then
      mkdir -p "$HOME/kali-deox-restaurado"
      tar -C "$HOME/kali-deox-restaurado" -xf "$tmp/firefox.tar"
      aviso "Perfil de Firefox en ~/kali-deox-restaurado/.mozilla (NO activado):"
      echo "     Kali usa Firefox ESR (más antiguo que el de CachyOS) y un perfil más nuevo puede"
      echo "     dar problemas. Lo seguro: usa Firefox Sync, o importa marcadores desde"
      echo "     ~/kali-deox-restaurado/.mozilla/firefox/*/bookmarkbackups/"
    fi
  fi
  ok "Restauración terminada."
}

case "${1:-}" in
  --restaurar) [ -n "${2:-}" ] || morir "Uso: $0 --restaurar /ruta/kali-deox-migracion"; restaurar "$2" ;;
  ""|-h|--help) sed -n '2,12p' "$0" ;;
  *) hacer_copia "$1" ;;
esac
