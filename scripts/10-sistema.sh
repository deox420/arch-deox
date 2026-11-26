#!/usr/bin/env bash
# 10-sistema.sh — base del sistema en Kali: repos, actualización, drivers Intel,
# idioma español y utilidades. Es seguro relanzarlo (idempotente).
#   bash scripts/10-sistema.sh
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

# --- 1) Repos oficiales --------------------------------------------------------
info "1/5 · Comprobar los repositorios de Kali"
# Kali solo debe usar SU repo oficial (kali-rolling). Mezclar repos de Debian
# o Ubuntu es la forma nº1 de romper Kali ("FrankenDebian").
fuentes="$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep -vE '^\s*#' | grep -E '^\s*deb' || true)"
fuentes+=$'\n'"$(cat /etc/apt/sources.list.d/*.sources 2>/dev/null | grep -E '^\s*URIs:' || true)"
if echo "$fuentes" | grep -qE 'http.kali.org/kali|kali.download/kali'; then
  ok "Repo oficial kali-rolling presente"
else
  aviso "No veo el repo oficial. Lo correcto es tener en /etc/apt/sources.list:"
  echo "      deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware"
  if ask "¿Lo escribo yo (guardo copia en /etc/apt/sources.list.bak)?"; then
    sudo cp -a /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
    echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' | sudo tee /etc/apt/sources.list >/dev/null
  fi
fi
if echo "$fuentes" | grep -vE 'kali' | grep -qE 'debian.org|ubuntu.com|launchpad'; then
  aviso "Tienes repos de Debian/Ubuntu mezclados con Kali. Quítalos: rompen el sistema."
fi
# Kali firma su repo con HTTPS opcional: apt verifica la firma GPG igualmente.
if ! echo "$fuentes" | grep -q 'non-free-firmware'; then
  aviso "Falta el componente 'non-free-firmware' (wifi/sonido Intel lo necesitan)."
fi

# --- 2) Actualización completa ---------------------------------------------------
info "2/5 · Actualizar TODO el sistema (apt full-upgrade)"
echo "   En Kali (rolling) siempre 'full-upgrade', nunca a medias."
if ask "¿Actualizo ahora?"; then
  sudo apt-get update
  sudo apt-get full-upgrade -y 2>&1 | tee -a "$LOG"
fi

# --- 3) Base + drivers -----------------------------------------------------------
info "3/5 · Drivers Intel, energía, red, sonido y utilidades (packages/base.txt)"
mapfile -t paqs < <(lista_paquetes "$REPO/packages/base.txt")
instalar_auditado "la base del sistema" "${paqs[@]}"

# --- 4) Idioma -------------------------------------------------------------------
info "4/5 · Español (es_ES.UTF-8) y teclado"
if locale -a 2>/dev/null | grep -qi '^es_ES.utf8$'; then
  ok "es_ES.UTF-8 ya generado"
elif ask "¿Genero el idioma es_ES.UTF-8 (fechas y textos en español)?"; then
  sudo sed -i 's/^# *\(es_ES.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  sudo locale-gen
fi
xdg-user-dirs-update 2>/dev/null || true

# --- 5) Energía y servicios del portátil -------------------------------------------
info "5/5 · Servicios del portátil (energía, bluetooth, red)"
if ask "¿Activo power-profiles-daemon, thermald, bluetooth y NetworkManager?"; then
  for s in power-profiles-daemon thermald bluetooth NetworkManager; do
    sudo systemctl enable --now "$s" 2>/dev/null && ok "$s" || aviso "$s no disponible"
  done
fi
echo "   Comprueba la aceleración de vídeo Intel con:  vainfo"

info "Sistema listo. Siguiente:  bash scripts/20-escritorio.sh"
