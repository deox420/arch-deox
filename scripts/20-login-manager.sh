#!/usr/bin/env bash
# 20-login-manager.sh — pantalla de login greetd + tuigreet (estilo terminal).
# ---------------------------------------------------------------------------
# Caelestia NO trae gestor de login: hay que poner uno. Usamos greetd con
# tuigreet (login en modo texto, sobrio y sci-fi, arranca Hyprland al entrar).
#
# Este script:
#   1. Instala greetd + greetd-tuigreet (repos oficiales).
#   2. Copia system/greetd-config.toml a /etc/greetd/config.toml.
#   3. Activa greetd para el próximo arranque.
#
# Lo lanzas TÚ en el portátil:  bash scripts/20-login-manager.sh
# ---------------------------------------------------------------------------
set -euo pipefail

info() { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ask()  { read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

if [ "$(id -u)" -eq 0 ]; then
  echo "No me ejecutes como root; ya pediré sudo yo donde haga falta." >&2
  exit 1
fi

DIR="$(cd "$(dirname "$0")/.." && pwd)"
CFG="$DIR/system/greetd-config.toml"
[ -f "$CFG" ] || { echo "No encuentro $CFG" >&2; exit 1; }

info "1/3 · Instalar greetd + tuigreet"
if ask "¿Instalo greetd y greetd-tuigreet?"; then
  sudo pacman -S --needed greetd greetd-tuigreet
fi

info "2/3 · Copiar la configuración a /etc/greetd/config.toml"
echo "   Origen:  $CFG"
if ask "¿Copio la config de greetd a /etc/greetd/config.toml?"; then
  sudo install -Dm644 "$CFG" /etc/greetd/config.toml
fi

info "3/3 · Activar greetd para el próximo arranque"
if ask "¿Activo greetd.service (systemctl enable)?"; then
  # Aviso: no deben quedar DOS gestores de login activos a la vez.
  if systemctl is-enabled display-manager.service >/dev/null 2>&1; then
    echo "   [!] Ya hay otro display-manager activo. Desactívalo antes:"
    echo "       sudo systemctl disable display-manager.service"
  fi
  sudo systemctl enable greetd.service
  echo "   Se estrena en el próximo reinicio."
fi

info "Login listo. Último paso: copiar tus overrides (ver overrides/README.md) y reiniciar."
