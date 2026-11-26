#!/usr/bin/env bash
# 20-escritorio.sh — el escritorio kali-deox: Hyprland + Waybar + Rofi + Mako +
# Kitty + login greetd/tuigreet, con tus dotfiles y el tema por defecto.
#   bash scripts/20-escritorio.sh
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

info "1/4 · Instalar los paquetes del escritorio (packages/escritorio.txt)"
mapfile -t paqs < <(lista_paquetes "$REPO/packages/escritorio.txt")
instalar_auditado "el escritorio Hyprland" "${paqs[@]}"

info "2/4 · Copiar la configuración (dotfiles) a tu usuario"
bash "$REPO/scripts/instalar-dotfiles.sh"

info "3/4 · Validar la configuración de Hyprland"
if command -v Hyprland >/dev/null; then
  salida="$(Hyprland --verify-config 2>&1 | tail -n 8 || true)"
  if grep -q 'config ok' <<<"$salida"; then
    ok "Configuración de Hyprland correcta"
  else
    echo "$salida" | sed 's/^/     /'
    aviso "Hyprland ha encontrado errores (arriba). Revisa ~/.config/hypr/usuario.lua"
  fi
fi

info "4/4 · Pantalla de login (greetd + tuigreet)"
bash "$REPO/scripts/25-login.sh"

info "Escritorio listo. Siguiente:  bash scripts/30-hacking.sh"
