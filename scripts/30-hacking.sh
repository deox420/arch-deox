#!/usr/bin/env bash
# 30-hacking.sh — herramientas de hacking ético / pentesting (repos oficiales de Kali).
# ---------------------------------------------------------------------------
# Tres capas, eliges tú:
#   1. Un METAPAQUETE de Kali (conjunto oficial):
#        kali-linux-default  ~12 GB  lo de la ISO estándar (nmap, metasploit,
#                                    burpsuite, sqlmap, hydra, john, wireshark…)
#        kali-linux-large    ~21 GB  default + mucho más (recomendado si hay disco)
#      (kali-linux-everything ~39 GB: no lo ofrezco, casi nadie lo necesita.)
#   2. CATEGORÍAS sueltas (kali-tools-wireless, -web, -forensics…).
#   3. EXTRAS que no trae default (packages/hacking-extra.txt): netexec,
#      bloodhound, ligolo-ng, nuclei, caido, pwntools, ghidra…
# Antes de instalar, cada bloque pasa por la auditoría de seguridad.
#
# ⚖  Úsalas SOLO contra sistemas tuyos o con permiso por escrito (CTFs, labs,
#    HackTheBox, TryHackMe, auditorías contratadas). Lo demás es delito.
# ---------------------------------------------------------------------------
source "$(dirname "$0")/lib.sh"
no_root; exigir_kali

instalado() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; }

# --- 1) Metapaquete ---------------------------------------------------------------
info "1/4 · Conjunto principal de herramientas"
for m in kali-linux-everything kali-linux-large kali-linux-default; do
  instalado "$m" && ok "Ya tienes $m"
done
cat <<'TXT'
   a) kali-linux-default   (~3 GB descarga, ~12 GB en disco)  ← lo estándar
   b) kali-linux-large     (~6 GB descarga, ~21 GB en disco)  ← más completo
   n) ninguno / ya lo tengo
TXT
if [ "${KALI_DEOX_SI:-0}" = 1 ]; then op="a"; else read -rp "   Elige [a/b/n]: " op; fi
case "$op" in
  a|A) instalar_auditado "kali-linux-default" kali-linux-default ;;
  b|B) instalar_auditado "kali-linux-large" kali-linux-large ;;
  *)   echo "   (saltado)" ;;
esac

# --- 2) Categorías ----------------------------------------------------------------
info "2/4 · Categorías extra (opcional)"
mapfile -t cats < <(apt-cache pkgnames kali-tools- 2>/dev/null | sort)
if [ "${#cats[@]}" -gt 0 ] && [ "${KALI_DEOX_SI:-0}" != 1 ]; then
  i=1
  for c in "${cats[@]}"; do
    marca=" "; instalado "$c" && marca="✓"
    printf '   %2d) [%s] %s\n' "$i" "$marca" "$c"; i=$((i + 1))
  done
  read -rp "   Números separados por espacios (Enter = ninguno): " -a elegidos
  sel=()
  for n in "${elegidos[@]}"; do
    [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#cats[@]}" ] && sel+=("${cats[$((n - 1))]}")
  done
  [ "${#sel[@]}" -gt 0 ] && instalar_auditado "categorías: ${sel[*]}" "${sel[@]}"
fi

# --- 3) Extras --------------------------------------------------------------------
info "3/4 · Extras modernos (packages/hacking-extra.txt)"
mapfile -t paqs < <(lista_paquetes "$REPO/packages/hacking-extra.txt")
instalar_auditado "los extras de hacking" "${paqs[@]}"

# --- 4) Ajustes ---------------------------------------------------------------------
info "4/4 · Ajustes para usar las herramientas sin sudo"
if getent group wireshark >/dev/null && ! id -nG "$USER" | grep -qw wireshark; then
  if ask "¿Te añado al grupo 'wireshark' (capturar tráfico sin ser root)?"; then
    sudo usermod -aG wireshark "$USER" && ok "Hecho (efectivo al volver a iniciar sesión)"
  fi
fi
if command -v msfdb >/dev/null && ask "¿Preparo la base de datos de Metasploit (msfdb init; solo escucha en local)?"; then
  sudo msfdb init || aviso "msfdb init falló; puedes repetirlo luego."
fi
mkdir -p "$HOME/cajas"
ok "Carpeta de trabajo: ~/cajas  (en la terminal: 'caja nombre-maquina')"
echo "   Listas de palabras: /usr/share/wordlists y /usr/share/seclists"
echo "   rockyou viene comprimido:  sudo gunzip /usr/share/wordlists/rockyou.txt.gz"

info "Herramientas listas. Siguiente:  bash scripts/40-seguridad.sh"
