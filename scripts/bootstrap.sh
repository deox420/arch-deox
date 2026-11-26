#!/usr/bin/env bash
# bootstrap.sh — monta kali-deox de un tirón sobre un Kali recién instalado.
# Encadena los pasos en orden y te pregunta en cada uno (puedes saltar
# cualquiera y relanzar cuando quieras: todo es idempotente).
#   bash scripts/bootstrap.sh
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

cat <<'TXT'
=============================================================
   kali-deox · montaje completo
   1) 10-sistema     repos, actualización, drivers Intel, español
   2) 20-escritorio  Hyprland + Waybar + Rofi + Kitty + login
   3) 30-hacking     herramientas (metapaquete + extras)
   4) 40-seguridad   cortafuegos, AppArmor, aviso semanal
   5) 50-snapshots   volver atrás si algo se rompe
   6) 60-copia       restaurar tus datos de CachyOS
   Cada instalación se audita contra vulnerabilidades conocidas.
   Registro: ~/.local/state/kali-deox/instalacion.log
=============================================================
TXT
hay_red || aviso "No llego a http.kali.org: revisa la conexión antes de seguir."
ask "¿Empezamos?" || exit 0

titulo "1 · Sistema";      ask "¿Ejecuto 10-sistema.sh?"    && bash "$REPO/scripts/10-sistema.sh"
titulo "2 · Escritorio";   ask "¿Ejecuto 20-escritorio.sh?" && bash "$REPO/scripts/20-escritorio.sh"
titulo "3 · Hacking";      ask "¿Ejecuto 30-hacking.sh?"    && bash "$REPO/scripts/30-hacking.sh"
titulo "4 · Seguridad";    ask "¿Ejecuto 40-seguridad.sh?"  && bash "$REPO/scripts/40-seguridad.sh"
titulo "5 · Snapshots";    ask "¿Ejecuto 50-snapshots.sh?"  && bash "$REPO/scripts/50-snapshots.sh"
titulo "6 · Tus datos"
if ask "¿Restauro la copia que hiciste en CachyOS?"; then
  read -rp "   Ruta de la carpeta kali-deox-migracion: " ruta
  bash "$REPO/scripts/60-copia.sh" --restaurar "$ruta"
fi

cat <<'TXT'

== ¡Listo! Reinicia (sudo reboot). En el login pulsa Enter → Hyprland. ==
   Primeros atajos: SUPER+Enter terminal · SUPER+D apps · SUPER+F1 chuleta
   Cambiar colores: SUPER+T · Seguridad: deox-auditar
TXT
