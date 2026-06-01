#!/usr/bin/env bash
# Menú de energía para Waybar (arch-deox), con wofi.
opt=$(printf "  Bloquear\n  Cerrar sesión\n  Suspender\n  Reiniciar\n  Apagar" \
    | wofi --dmenu --prompt "Energía" --width 260 --height 260 --cache-file /dev/null)

case "$opt" in
    *Bloquear*)      hyprlock ;;
    *Cerrar*)        hyprctl dispatch exit ;;
    *Suspender*)     systemctl suspend ;;
    *Reiniciar*)     systemctl reboot ;;
    *Apagar*)        systemctl poweroff ;;
esac
