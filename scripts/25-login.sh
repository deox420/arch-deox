#!/usr/bin/env bash
# 25-login.sh — login en modo texto (greetd + tuigreet) que arranca Hyprland.
# Si al instalar Kali elegiste un escritorio (XFCE/KDE), éste traerá su propio
# login (lightdm/sddm). Solo puede haber UNO activo: aquí te ofrezco cambiarlo.
# Tu escritorio anterior sigue disponible: en tuigreet pulsa F3 para elegir sesión.
#   bash scripts/25-login.sh
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

CFG="$REPO/sistema/greetd-config.toml"
[ -f "$CFG" ] || morir "No encuentro $CFG"
command -v tuigreet >/dev/null || morir "Falta tuigreet (sudo apt install greetd tuigreet)."

info "Copiar la configuración a /etc/greetd/config.toml"
if ask "¿Instalo la config de greetd (guardo copia de la actual)?"; then
  [ -f /etc/greetd/config.toml ] && sudo cp -a /etc/greetd/config.toml "/etc/greetd/config.toml.bak.$(date +%s)"
  sudo install -Dm644 "$CFG" /etc/greetd/config.toml
  ok "Config instalada"
fi

info "Elegir greetd como gestor de login"
actual=""
if [ -L /etc/systemd/system/display-manager.service ]; then
  actual="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service)"
fi
echo "   Gestor actual: ${actual:-ninguno}"
if [ "$actual" = "greetd" ]; then
  ok "greetd ya es el gestor de login"
elif ask "¿Cambio a greetd? (${actual:-ninguno} quedará desactivado, no desinstalado)"; then
  if [ -n "$actual" ]; then sudo systemctl disable "$actual" 2>/dev/null || true; fi
  sudo systemctl enable greetd.service
  ok "greetd activado: se estrena en el próximo reinicio"
  echo "   ¿Algo falla? En otra consola (Ctrl+Alt+F2) entra y vuelve atrás con:"
  echo "       sudo systemctl disable greetd && sudo systemctl enable ${actual:-lightdm}"
fi
