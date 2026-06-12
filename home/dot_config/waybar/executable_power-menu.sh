#!/usr/bin/env bash
# Menú de energía para Waybar (arch-deox), con rofi (el mismo lanzador de siempre).
opt=$(printf "  Bloquear\n  Cerrar sesión\n  Suspender\n  Reiniciar\n  Apagar" \
    | rofi -dmenu -i -p "Energía" -theme-str 'window { width: 280px; } listview { lines: 5; }')

case "$opt" in
    *Bloquear*)      hyprlock ;;
    *Cerrar*)        hyprctl dispatch exit ;;
    *Suspender*)     systemctl suspend ;;
    *Reiniciar*)     systemctl reboot ;;
    *Apagar*)        systemctl poweroff ;;
esac
