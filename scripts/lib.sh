#!/usr/bin/env bash
# lib.sh — funciones comunes de los scripts de kali-deox. Se carga con:
#     source "$(dirname "$0")/lib.sh"
# No hace nada por sí solo.
# shellcheck disable=SC2034  # variables usadas por los scripts que cargan esto

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/kali-deox"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/instalacion.log"

# Paquetes que NUNCA queremos que entren como "recomendados":
#   exim4  → servidor de correo que arrastran timeshift/debsecan: no hace falta
#            y es un servicio de red más que vigilar.
#   libmodplug1 → lector de módulos de música con CVEs sin arreglar en Kali.
# Solo se excluyen si NO están ya instalados (si lo estuvieran, "paquete-"
# los desinstalaría, y eso no lo queremos hacer a escondidas).
EXCLUIR=()
for _p in exim4-base exim4-daemon-light exim4-config libmodplug1; do
  dpkg-query -W -f='${Status}' "$_p" 2>/dev/null | grep -q 'install ok installed' || EXCLUIR+=("$_p-")
done
unset _p

# --- Mensajes -----------------------------------------------------------------
titulo() { printf '\n\033[1;35m########  %s  ########\033[0m\n' "$*"; }
info()   { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ok()     { printf '   \033[1;32m✓\033[0m %s\n' "$*"; }
aviso()  { printf '   \033[1;33m!\033[0m %s\n' "$*"; }
error()  { printf '   \033[1;31m✗ %s\033[0m\n' "$*" >&2; }
morir()  { error "$*"; exit 1; }

# ask "¿pregunta?"  → 0 si contesta s/S/y/Y.
# Con KALI_DEOX_SI=1 contesta "sí" solo (modo desatendido, para pruebas).
ask() {
  if [ "${KALI_DEOX_SI:-0}" = 1 ]; then printf '\033[1;33m%s [s/N] s (auto)\033[0m\n' "$1"; return 0; fi
  local r
  read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r || return 1
  [[ "$r" =~ ^[sSyY]$ ]]
}

# --- Comprobaciones -----------------------------------------------------------
no_root() {
  [ "$(id -u)" -ne 0 ] || morir "No me ejecutes como root. Usa tu usuario normal; pediré sudo cuando haga falta."
}

es_kali() {
  [ -r /etc/os-release ] && grep -qi '^ID=kali' /etc/os-release
}

exigir_kali() {
  es_kali || morir "Esto es para Kali Linux. Si aún estás en CachyOS, usa:  bash migrar.sh"
}

hay_red() {
  curl -fsS -m 10 -o /dev/null https://http.kali.org/kali/dists/kali-rolling/Release
}

# lista_paquetes fichero  → imprime los nombres (sin comentarios ni líneas vacías)
lista_paquetes() {
  sed 's/#.*//' "$1" | tr -s '[:space:]' '\n' | sed '/^$/d'
}

# --- Instalar con auditoría previa --------------------------------------------
# instalar_auditado "descripción" paquete1 paquete2 …
#   1) comprueba que todos existen en los repos,
#   2) audita con deox-auditar lo que se va a instalar (dependencias incluidas),
#   3) pregunta y 4) instala.
instalar_auditado() {
  local desc="$1"; shift
  local faltan=() p
  for p in "$@"; do
    apt-cache show "$p" >/dev/null 2>&1 || faltan+=("$p")
  done
  if [ "${#faltan[@]}" -gt 0 ]; then
    aviso "No existen en los repos (los salto): ${faltan[*]}"
    local quedan=()
    for p in "$@"; do [[ " ${faltan[*]} " == *" $p "* ]] || quedan+=("$p"); done
    set -- "${quedan[@]}"
  fi
  [ "$#" -gt 0 ] || { aviso "Nada que instalar."; return 0; }

  info "Auditoría de seguridad de: $desc"
  local auditor
  auditor="$(command -v deox-auditar || echo "$REPO/dotfiles/bin/deox-auditar")"
  auditor=(python3 -I "$auditor")
  if python3 -c 'import apt_pkg' 2>/dev/null; then
    "${auditor[@]}" --simular "$@" ${EXCLUIR[@]+"${EXCLUIR[@]}"} || true
  else
    aviso "Falta python3-apt: instalo eso primero para poder auditar."
    sudo apt-get install -y python3-apt
    "${auditor[@]}" --simular "$@" ${EXCLUIR[@]+"${EXCLUIR[@]}"} || true
  fi
  echo "   [EN CAMINO] = arreglos que Kali aún no ha publicado: llegan con 'sudo apt full-upgrade'."
  ask "¿Instalo $desc ($# paquetes + dependencias)?" || { aviso "Saltado."; return 0; }
  sudo apt-get install -y "$@" ${EXCLUIR[@]+"${EXCLUIR[@]}"} 2>&1 | tee -a "$LOG"
  return "${PIPESTATUS[0]}"
}
