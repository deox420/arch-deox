#!/usr/bin/env bash
# setup-sistema.sh — pasos de SISTEMA del mantenimiento 2026-06-12 (fases 4 y 5).
# Ejecutar:  sudo bash ~/.local/share/chezmoi/system/setup-sistema.sh
# Es idempotente: si algo ya está hecho, lo salta sin romper nada.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Ejecútame con sudo:  sudo bash $0" >&2
  exit 1
fi

REPO="/home/deox/.local/share/chezmoi"

echo "== [1/5] Paquetes nuevos (repos oficiales) =="
pacman -S --needed obsidian qt5-wayland qt6-wayland gvfs tumbler thunar-volman \
  noto-fonts noto-fonts-emoji bash-completion cliphist wl-clip-persist \
  ufw greetd greetd-tuigreet

echo "== [2/5] Quitar paru-debug (paquete de depuración que sobra) =="
pacman -Rns --noconfirm paru-debug 2>/dev/null || echo "   (ya no estaba)"

echo "== [3/5] greetd: config + activar para el próximo arranque =="
install -Dm644 "$REPO/system/greetd-config.toml" /etc/greetd/config.toml
systemctl enable greetd.service

echo "== [4/5] Firewall ufw: denegar entrante / permitir saliente =="
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
systemctl enable ufw.service

echo "== [5/5] Estado final =="
ufw status verbose
systemctl is-enabled greetd.service ufw.service
echo
echo "== TODO OK == (greetd se estrena en el próximo reinicio)"
