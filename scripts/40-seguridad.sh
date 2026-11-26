#!/usr/bin/env bash
# 40-seguridad.sh — proteger TU portátil (el atacante también es objetivo).
#   1. Cortafuegos ufw: bloquea lo entrante, permite lo saliente.
#   2. Revisar qué servicios escuchan en la red.
#   3. AppArmor activo.
#   4. Aviso semanal de actualizaciones de seguridad (deox-auditar).
#   bash scripts/40-seguridad.sh
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

info "1/4 · Cortafuegos (ufw)"
if command -v ufw >/dev/null && ask "¿Activo ufw (denegar entrante / permitir saliente)?"; then
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
  sudo systemctl enable ufw >/dev/null 2>&1 || true
  ok "ufw activo"
  echo "   Para recibir una reverse shell abre el puerto SOLO en tu VPN, p.ej.:"
  echo "       sudo ufw allow in on tun0 to any port 4444 proto tcp"
  echo "   y ciérralo al acabar:  sudo ufw delete allow in on tun0 to any port 4444 proto tcp"
fi

info "2/4 · Servicios escuchando en la red"
# Kali deja los servicios de red (ssh, apache, postgres…) DESACTIVADOS de serie.
# Aquí solo miramos que siga siendo así.
ss -tulpnH 2>/dev/null | awk '{print "   " $1, $5}' | grep -vE ' (127\.|\[::1\]|::1)' || true
echo "   (Si ves algo en 0.0.0.0 o [::] que no conoces, páralo: sudo systemctl disable --now <servicio>)"

info "3/4 · AppArmor"
if command -v aa-status >/dev/null; then
  if sudo aa-status --enabled 2>/dev/null; then ok "AppArmor activo"
  elif ask "¿Activo AppArmor?"; then sudo systemctl enable --now apparmor && ok "Activado (completo tras reiniciar)"
  fi
fi

info "4/4 · Aviso semanal de seguridad"
if ask "¿Programo un aviso semanal con el resultado de deox-auditar?"; then
  u="$HOME/.config/systemd/user"; mkdir -p "$u"
  cat > "$u/deox-auditar.service" <<'UNIT'
[Unit]
Description=kali-deox: auditoría de seguridad de paquetes

[Service]
Type=oneshot
Environment=PATH=%h/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/bin/sh -c 'r="$(deox-auditar --resumen)"; s=$?; [ "$s" = 2 ] && u=critical || u=normal; notify-send -u "$u" -a kali-deox "Seguridad" "$r · ejecuta deox-auditar para detalles" || true'
UNIT
  cat > "$u/deox-auditar.timer" <<'UNIT'
[Unit]
Description=kali-deox: auditoría semanal

[Timer]
OnCalendar=weekly
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
UNIT
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now deox-auditar.timer 2>/dev/null && ok "Aviso semanal activado" \
    || aviso "No pude activarlo ahora (¿sin sesión gráfica?). Hazlo luego: systemctl --user enable --now deox-auditar.timer"
fi

info "Auditoría ahora mismo:"
if command -v deox-auditar >/dev/null; then deox-auditar || true
else python3 -I "$REPO/dotfiles/bin/deox-auditar" || true; fi
info "Seguridad lista. Siguiente:  bash scripts/50-snapshots.sh"
