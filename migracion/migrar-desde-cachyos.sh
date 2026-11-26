#!/usr/bin/env bash
# migrar-desde-cachyos.sh — prepara el salto de CachyOS (Arch) a Kali Linux.
# ---------------------------------------------------------------------------
# Se ejecuta EN TU CACHYOS ACTUAL. No toca tu sistema: solo LEE tus datos,
# los copia a un disco externo y prepara un USB de instalación de Kali.
#
#   bash migracion/migrar-desde-cachyos.sh            (asistente completo)
#   bash migracion/migrar-desde-cachyos.sh copia      solo paso 1
#   bash migracion/migrar-desde-cachyos.sh iso        solo paso 2
#   bash migracion/migrar-desde-cachyos.sh usb        solo paso 3
#
# Pasos:
#   1. COPIA de tus datos a un disco externo (documentos, fotos, claves SSH,
#      git, wifi…) con verificación de integridad (sha256). Lo sensible
#      (claves, contraseñas wifi) va CIFRADO con una contraseña que eliges.
#   2. ISO de Kali: descarga la última, comprueba la FIRMA OFICIAL de Kali
#      (GPG) y el hash SHA256. Si algo no cuadra, se borra y se aborta.
#   3. USB: graba la ISO en un pendrive (≥ 8 GB) — con mil comprobaciones
#      para no borrar el disco equivocado — y verifica lo grabado.
#   4. Te explica cómo instalar Kali y cómo restaurar todo después.
#
# ⚠ Instalar Kali BORRA el disco del portátil. Por eso el paso 1 es obligatorio
#   antes del 3, y el script comprueba que la copia está completa.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TRABAJO="${XDG_CACHE_HOME:-$HOME/.cache}/kali-deox-migracion"
mkdir -p "$TRABAJO"
LOG="$TRABAJO/migracion.log"
ESTADO="$TRABAJO/estado"

# Clave oficial de firma de Kali (desde 2025). Verifícala tú también en
# https://www.kali.org/docs/introduction/download-official-kali-linux-images/
KALI_FPR="827C8569F2518CC677FECA1AED65462EC8D5E4C5"
KALI_KEY_URL="https://archive.kali.org/archive-key.asc"
ESPEJOS=("https://cdimage.kali.org/current" "https://kali.download/base-images/current")

titulo() { printf '\n\033[1;35m########  %s  ########\033[0m\n' "$*"; }
info()   { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ok()     { printf '   \033[1;32m✓\033[0m %s\n' "$*"; }
aviso()  { printf '   \033[1;33m!\033[0m %s\n' "$*"; }
morir()  { printf '   \033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
ask() {
  if [ "${KALI_DEOX_SI:-0}" = 1 ]; then echo "$1 [s/N] s (auto)"; return 0; fi
  local r; read -rp "$(printf '\033[1;33m%s [s/N] \033[0m' "$1")" r || return 1; [[ "$r" =~ ^[sSyY]$ ]]
}
# disco_de RUTA → disco físico (/dev/sda, /dev/nvme0n1) que contiene esa ruta,
# atravesando LUKS, LVM, RAID y subvolúmenes Btrfs.
disco_de() {
  local src
  src="$(findmnt -no SOURCE --target "$1" 2>/dev/null | head -1 | sed 's/\[.*//')"
  [ -b "$src" ] || return 0
  lsblk -nspo NAME,TYPE "$src" 2>/dev/null | awk '$2=="disk"{print $1}' | sed 's/^[^/]*//' | sort -u
}
guardar_estado() { echo "$1=$2" >> "$ESTADO"; }
leer_estado()    { { grep -E "^$1=" "$ESTADO" 2>/dev/null || true; } | tail -1 | cut -d= -f2-; }

[ "$(id -u)" -ne 0 ] || morir "No me ejecutes como root; pediré sudo solo donde haga falta."

# --- Comprobaciones previas ---------------------------------------------------------
previas() {
  info "Comprobaciones previas"
  if command -v pacman >/dev/null; then ok "Estás en una distro tipo Arch ($(. /etc/os-release; echo "${PRETTY_NAME:-?}"))"
  else aviso "No parece Arch/CachyOS. El script funciona igual en otras distros (solo cambia cómo instalar lo que falte)."; fi
  local faltan=()
  for c in rsync curl gpg sha256sum lsblk findmnt dd tar xdg-user-dir; do
    command -v "$c" >/dev/null || faltan+=("$c")
  done
  if [ "${#faltan[@]}" -gt 0 ]; then
    aviso "Faltan herramientas: ${faltan[*]}"
    if command -v pacman >/dev/null && ask "¿Las instalo con pacman (rsync gnupg coreutils util-linux tar xdg-user-dirs curl)?"; then
      sudo pacman -S --needed rsync gnupg coreutils util-linux tar xdg-user-dirs curl
    else
      morir "Instálalas y vuelve a lanzarme."
    fi
  fi
  ok "Herramientas necesarias presentes"
  if [ -r /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online)" = 0 ]; then
    aviso "Estás con batería. Enchufa el cargador: copiar y grabar tarda un rato."
  fi
}

# --- Elegir disco externo ---------------------------------------------------------
elegir_destino() {
  info "¿Dónde guardo la copia? (un disco externo/USB DISTINTO del pendrive de Kali)"
  echo "   Discos montados ahora mismo:"
  findmnt -rno TARGET,SOURCE,FSTYPE,SIZE,AVAIL -t ext4,btrfs,xfs,exfat,vfat,ntfs,ntfs3,fuseblk 2>/dev/null \
    | awk '{printf "     %-40s %-16s %-6s libre %s\n", $1, $2, $3, $5}' | grep -vE '^\s+/(boot|efi)?\s' || true
  local d
  d="$(leer_estado destino)"
  if [ -n "${KALI_DEOX_DESTINO:-}" ]; then d="$KALI_DEOX_DESTINO"
  else read -rp "   Ruta de la carpeta destino [${d:-/run/media/$USER/…}]: " r; d="${r:-$d}"; fi
  [ -n "$d" ] || morir "Necesito una ruta."
  d="${d%/}"
  [ -d "$d" ] || morir "No existe la carpeta $d (¿está el disco montado?)."
  local disco_root disco_dest
  disco_root="$(disco_de /)"
  disco_dest="$(disco_de "$d")"
  if [ -n "$disco_root" ] && grep -qxF -f <(echo "$disco_root") <(echo "$disco_dest"); then
    aviso "¡Esa carpeta está en el MISMO disco que vas a borrar al instalar Kali ($disco_root)!"
    [ "${KALI_DEOX_PERMITIR_MISMO_DISCO:-0}" = 1 ] || morir "Usa un disco externo."
  fi
  [ -w "$d" ] || morir "No puedo escribir en $d."
  DESTINO="$d/kali-deox-migracion"
  mkdir -p "$DESTINO"
  guardar_estado destino "$d"
  ok "Copia en: $DESTINO"
}

# --- Paso 1: copia ------------------------------------------------------------------
copia() {
  titulo "PASO 1 · Copia de seguridad de tus datos"
  elegir_destino
  mkdir -p "$DESTINO"/{datos,info}

  # Carpetas personales por su "tipo" XDG (así se restauran bien aunque en Kali
  # se llamen distinto: Documentos/Documents…).
  local tipos=(DESKTOP DOCUMENTS DOWNLOAD MUSIC PICTURES VIDEOS TEMPLATES PUBLICSHARE)
  local total=0 t src
  info "Tamaño de lo que se va a copiar"
  for t in "${tipos[@]}"; do
    src="$(xdg-user-dir "$t" 2>/dev/null || true)"
    [ -n "$src" ] && [ "$src" != "$HOME" ] && [ -d "$src" ] || continue
    printf '     %-12s %-45s %s\n' "$t" "${src/#$HOME/\~}" "$(du -sh "$src" 2>/dev/null | cut -f1)"
    total=$((total + $(du -sk "$src" 2>/dev/null | cut -f1)))
  done
  local extra=()
  for e in cajas Proyectos proyectos Projects dev src Code Notas notas Obsidian; do
    [ -d "$HOME/$e" ] && extra+=("$e") && printf '     %-12s %-45s %s\n' "EXTRA" "~/$e" "$(du -sh "$HOME/$e" | cut -f1)" \
      && total=$((total + $(du -sk "$HOME/$e" | cut -f1)))
  done
  local libre; libre=$(df --output=avail -k "$DESTINO" | tail -1)
  echo "     Total ≈ $((total / 1024)) MB · libre en destino ≈ $((libre / 1024)) MB"
  [ "$libre" -gt $((total + 1048576)) ] || morir "No cabe (deja al menos 1 GB de margen)."
  echo "   ¿Otras carpetas de tu home que quieras copiar? (nombres separados por espacio, Enter = no)"
  local mas=()
  [ "${KALI_DEOX_SI:-0}" = 1 ] || read -rp "   > " -a mas
  for m in "${mas[@]}"; do [ -d "$HOME/$m" ] && extra+=("$m") || aviso "No existe ~/$m (la salto)"; done

  ask "¿Empiezo la copia?" || { aviso "Copia cancelada."; return 1; }

  for t in "${tipos[@]}"; do
    src="$(xdg-user-dir "$t" 2>/dev/null || true)"
    [ -n "$src" ] && [ "$src" != "$HOME" ] && [ -d "$src" ] || continue
    echo "   · $t"
    mkdir -p "$DESTINO/datos/$t"
    rsync -aHAX --info=progress2 --no-inc-recursive "$src"/ "$DESTINO/datos/$t"/ 2>>"$LOG" \
      || rsync -aH --info=progress2 "$src"/ "$DESTINO/datos/$t"/   # exFAT/NTFS no guardan ACL/xattr
  done
  for e in "${extra[@]}"; do
    echo "   · ~/$e"
    mkdir -p "$DESTINO/datos/EXTRA/$e"
    rsync -aH --info=progress2 "$HOME/$e"/ "$DESTINO/datos/EXTRA/$e"/
  done

  # Configuración útil y NO sensible.
  info "Configuración (git, alias, lista de programas)"
  [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$DESTINO/info/gitconfig"
  for f in .bashrc .zshrc .config/fish/config.fish .config/starship.toml; do
    [ -f "$HOME/$f" ] && mkdir -p "$DESTINO/info/dotfiles-viejos/$(dirname "$f")" && cp "$HOME/$f" "$DESTINO/info/dotfiles-viejos/$f"
  done
  command -v pacman >/dev/null && pacman -Qqe > "$DESTINO/info/paquetes-cachyos.txt" || true
  command -v flatpak >/dev/null && flatpak list --app --columns=application > "$DESTINO/info/flatpaks.txt" 2>/dev/null || true
  git -C "$REPO" bundle create "$DESTINO/info/kali-deox-repo.bundle" --all >/dev/null 2>&1 \
    && ok "Copia de este repo (por si no tienes internet): info/kali-deox-repo.bundle"
  ok "Configuración copiada"

  # Lo SENSIBLE va cifrado (claves SSH/GPG, contraseñas wifi, perfil del navegador).
  info "Datos sensibles (cifrados con una contraseña que eliges tú)"
  local sens=()
  [ -d "$HOME/.ssh" ]   && sens+=(".ssh")   && echo "     · claves SSH (~/.ssh)"
  [ -d "$HOME/.gnupg" ] && sens+=(".gnupg") && echo "     · claves GPG (~/.gnupg)"
  [ -d "$HOME/.mozilla/firefox" ] && echo "     · perfil de Firefox (marcadores, contraseñas guardadas…)"
  local wifi=0
  if [ -d /etc/NetworkManager/system-connections ] && ask "   ¿Incluyo tus redes wifi guardadas (necesita sudo)?"; then wifi=1; fi
  local ff=0
  [ -d "$HOME/.mozilla/firefox" ] && ask "   ¿Incluyo el perfil de Firefox?" && ff=1
  if [ "${#sens[@]}" -gt 0 ] || [ "$wifi" = 1 ] || [ "$ff" = 1 ]; then
    local tmp; tmp="$(mktemp -d)"; chmod 700 "$tmp"
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN
    [ "${#sens[@]}" -gt 0 ] && tar -C "$HOME" -cf "$tmp/home-secretos.tar" "${sens[@]}"
    [ "$ff" = 1 ] && tar -C "$HOME" -cf "$tmp/firefox.tar" .mozilla/firefox
    if [ "$wifi" = 1 ]; then
      sudo tar -C /etc/NetworkManager -cf "$tmp/wifi.tar" system-connections
      sudo chown "$USER" "$tmp/wifi.tar"
    fi
    local partes=()
    for f in home-secretos.tar firefox.tar wifi.tar; do [ -f "$tmp/$f" ] && partes+=("$f"); done
    tar -C "$tmp" -cf "$tmp/secretos.tar" "${partes[@]}"
    echo "   Elige una contraseña para cifrar (AES-256). ¡Apúntala! Sin ella no hay vuelta."
    gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback -o "$DESTINO/secretos.tar.gpg" "$tmp/secretos.tar" \
      || gpg --symmetric --cipher-algo AES256 -o "$DESTINO/secretos.tar.gpg" "$tmp/secretos.tar"
    ok "secretos.tar.gpg creado (cifrado)"
  fi

  info "Verificación de integridad (sha256 de cada fichero; puede tardar)"
  ( cd "$DESTINO" && find datos info -type f -print0 | sort -z | xargs -0 -r sha256sum > MANIFIESTO.sha256 \
    && { [ ! -f secretos.tar.gpg ] || sha256sum secretos.tar.gpg >> MANIFIESTO.sha256; } )
  ( cd "$DESTINO" && sha256sum -c --quiet MANIFIESTO.sha256 ) || morir "¡La verificación ha fallado! No sigas: revisa el disco."
  date -Iseconds > "$DESTINO/COPIA-COMPLETA"
  sync
  ok "Copia COMPLETA y verificada: $(wc -l < "$DESTINO/MANIFIESTO.sha256") ficheros"
  guardar_estado copia_ok "$DESTINO"
}

# --- Paso 2: ISO ---------------------------------------------------------------------
iso() {
  titulo "PASO 2 · Descargar y VERIFICAR la ISO oficial de Kali"
  local dir="$TRABAJO/iso"; mkdir -p "$dir"
  local G="$TRABAJO/gnupg"; mkdir -p "$G"; chmod 700 "$G"

  info "Clave de firma oficial de Kali"
  curl -fsSL "$KALI_KEY_URL" -o "$dir/archive-key.asc"
  gpg --homedir "$G" --quiet --import "$dir/archive-key.asc" 2>/dev/null
  gpg --homedir "$G" --list-keys --with-colons "$KALI_FPR" 2>/dev/null | grep -q "^fpr:::::::::$KALI_FPR:" \
    || morir "La clave descargada NO coincide con la huella oficial $KALI_FPR. Aborto."
  ok "Huella correcta: $KALI_FPR"

  info "Lista de ISOs firmada"
  local base=""
  for e in "${ESPEJOS[@]}"; do
    if curl -fsSL "$e/SHA256SUMS" -o "$dir/SHA256SUMS" && curl -fsSL "$e/SHA256SUMS.gpg" -o "$dir/SHA256SUMS.gpg"; then
      base="$e"; break
    fi
  done
  [ -n "$base" ] || morir "No pude descargar SHA256SUMS de ningún espejo."
  gpg --homedir "$G" --status-fd 1 --verify "$dir/SHA256SUMS.gpg" "$dir/SHA256SUMS" 2>/dev/null \
    | grep -q "^\[GNUPG:\] VALIDSIG $KALI_FPR" || morir "¡FIRMA NO VÁLIDA en SHA256SUMS! Aborto (posible manipulación)."
  ok "SHA256SUMS firmado por Kali (espejo: $base)"

  local nombre
  nombre="$(awk '{print $2}' "$dir/SHA256SUMS" | grep -E '^kali-linux-[0-9.]+-installer-amd64\.iso$' | sort -V | tail -1)"
  [ -n "$nombre" ] || morir "No encuentro la ISO 'installer-amd64' en la lista."
  local hash; hash="$(awk -v n="$nombre" '$2==n{print $1}' "$dir/SHA256SUMS")"
  echo "   Última ISO: $nombre (~5 GB, instalador completo, funciona sin internet)"
  ISO="$dir/$nombre"

  if [ -f "$ISO" ] && echo "$hash  $ISO" | sha256sum -c --quiet 2>/dev/null; then
    ok "Ya descargada y correcta"
  else
    local libre; libre=$(df --output=avail -k "$dir" | tail -1)
    [ "$libre" -gt 6000000 ] || morir "Necesito ~6 GB libres en $dir."
    ask "¿Descargo $nombre (~5 GB)?" || { aviso "Saltado."; return 0; }
    curl -fL --retry 5 -C - "$base/$nombre" -o "$ISO.part"
    mv "$ISO.part" "$ISO"
    info "Comprobando SHA256 (1-2 min)…"
    echo "$hash  $ISO" | sha256sum -c --quiet || { rm -f "$ISO"; morir "El hash NO coincide: ISO corrupta o manipulada. Borrada."; }
    ok "ISO íntegra y auténtica"
  fi
  guardar_estado iso "$ISO"
}

# --- Paso 3: USB ---------------------------------------------------------------------
usb() {
  titulo "PASO 3 · Grabar la ISO en un pendrive"
  local iso_f; iso_f="${ISO:-$(leer_estado iso)}"
  [ -f "$iso_f" ] || morir "No tengo ISO verificada. Ejecuta antes el paso 2 (iso)."
  if [ -z "$(leer_estado copia_ok)" ] && [ "${KALI_DEOX_SIN_COPIA:-0}" != 1 ]; then
    morir "Primero haz la copia (paso 1). Instalar Kali borra el disco del portátil."
  fi
  local tam_iso; tam_iso=$(stat -c %s "$iso_f")

  local disco_root disco_copia=""
  disco_root="$(disco_de /)"
  [ -n "$(leer_estado destino)" ] && disco_copia="$(disco_de "$(leer_estado destino)")"

  info "Pendrives conectados (USB, extraíbles)"
  echo "   Mete AHORA el pendrive (≥ 8 GB). Se BORRARÁ entero."
  [ "${KALI_DEOX_SI:-0}" = 1 ] || read -rp "   Pulsa Enter cuando esté conectado… " _
  lsblk -dpno NAME,SIZE,TRAN,RM,MODEL | awk '$3=="usb" || $4=="1"' | sed 's/^/     /'
  local dev
  if [ -n "${KALI_DEOX_USB:-}" ]; then dev="$KALI_DEOX_USB"; else read -rp "   Escribe el dispositivo COMPLETO (ej. /dev/sdb): " dev; fi
  [ -b "$dev" ] || morir "$dev no es un dispositivo de bloque."
  local tipo; tipo="$(lsblk -dno TYPE "$dev" | tr -d ' ')"
  # (tipo "loop" solo se acepta en las pruebas automáticas del repo)
  if [ "$tipo" != disk ] && ! { [ "$tipo" = loop ] && [ "${KALI_DEOX_PERMITIR_NO_USB:-0}" = 1 ]; }; then
    morir "$dev es una partición ($tipo); quiero el disco entero (/dev/sdX, sin número)."
  fi
  dev="$(readlink -f "$dev")"
  local nombre_dev; nombre_dev="$(basename "$dev")"
  if [ -z "$disco_root" ]; then morir "No sé identificar el disco del sistema; por seguridad no sigo."; fi
  if echo "$disco_root" | grep -qxF "$dev"; then morir "¡$dev es el disco de tu sistema! Aborto."; fi
  if [ -n "$disco_copia" ] && echo "$disco_copia" | grep -qxF "$dev"; then morir "¡$dev es el disco donde está tu copia! Aborto."; fi
  if findmnt -rno SOURCE | sed 's/\[.*//' | grep -q "^$dev"; then
    lsblk -nlpo NAME,MOUNTPOINTS "$dev" | awk '$2 ~ /^\/(boot|home|efi)?$/' | grep -q . && morir "¡$dev tiene montado /, /home o /boot! Aborto."
  fi
  local tran rm_
  tran="$(lsblk -dno TRAN "$dev" | tr -d ' ')"; rm_="$(lsblk -dno RM "$dev" | tr -d ' ')"
  if [ "$tran" != usb ] && [ "$rm_" != 1 ] && [ "${KALI_DEOX_PERMITIR_NO_USB:-0}" != 1 ]; then
    morir "$dev no es USB ni extraíble. Por seguridad no lo toco."
  fi
  local tam_dev; tam_dev=$(lsblk -bdno SIZE "$dev")
  [ "$tam_dev" -ge "$tam_iso" ] || morir "El pendrive es demasiado pequeño ($((tam_dev / 1000000000)) GB)."

  echo
  lsblk -po NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$dev" | sed 's/^/     /'
  printf '\n   \033[1;31mSe BORRARÁ TODO en %s (%s %s).\033[0m\n' "$dev" "$(lsblk -dno SIZE "$dev")" "$(lsblk -dno MODEL "$dev")"
  local conf
  if [ "${KALI_DEOX_SI:-0}" = 1 ]; then conf="$nombre_dev"; else read -rp "   Para confirmar escribe su nombre ($nombre_dev): " conf; fi
  [ "$conf" = "$nombre_dev" ] || morir "No coincide. No he tocado nada."

  info "Desmontando particiones del pendrive"
  local p
  for p in $(lsblk -lnpo NAME "$dev" | tail -n +2); do
    findmnt -rno TARGET "$p" >/dev/null 2>&1 && { sudo umount "$p" || morir "No pude desmontar $p"; }
  done

  info "Grabando (no lo saques)…"
  sudo dd if="$iso_f" of="$dev" bs=4M conv=fsync oflag=direct status=progress
  sync

  info "Verificando lo grabado"
  if sudo cmp -n "$tam_iso" "$iso_f" "$dev"; then
    ok "Pendrive grabado y verificado byte a byte"
  else
    morir "La verificación falló: pendrive defectuoso o se desconectó. Repite con otro."
  fi
  sudo eject "$dev" 2>/dev/null || true
  guardar_estado usb_ok "$dev"
}

# --- Paso 4: instrucciones -------------------------------------------------------------
instrucciones() {
  titulo "PASO 4 · Instalar Kali y volver a tener TODO"
  cat <<TXT
  1. Reinicia con el pendrive puesto y entra al menú de arranque
     (en Medion suele ser F10 o F11; si no, F2/Supr para la BIOS).
     Si no arranca: en la BIOS desactiva temporalmente "Secure Boot".
  2. Elige "Graphical install" y en el asistente:
       · Idioma: Español · País: España · Teclado: Español
       · Nombre del equipo: kali-deox · Usuario: deox
       · Disco: "Guiado - utilizar todo el disco y configurar LVM CIFRADO"
         (recomendado en un portátil de hacking: si te lo roban, nadie lee nada)
       · Selección de software:
           [x] Desktop environment  +  [x] Xfce  (escritorio de reserva, ligero)
           [x] top10 / default tools  (o desmárcalo y elige luego en el paso 30)
  3. Primer arranque en Kali (entras en Xfce). Abre una terminal y:
       sudo apt update && sudo apt install -y git
       git clone https://github.com/deox420/arch-deox.git ~/kali-deox
       cd ~/kali-deox && bash migrar.sh
     (sin internet: conecta el disco de la copia y usa el bundle:
       git clone <disco>/kali-deox-migracion/info/kali-deox-repo.bundle ~/kali-deox)
  4. Al final del asistente, restaura tus datos:
       bash scripts/60-copia.sh --restaurar <disco>/kali-deox-migracion
  5. Reinicia: aparecerá el login kali-deox. Enter → Hyprland. ¡Listo!
TXT
}

# --- Principal ---------------------------------------------------------------------------
previas
case "${1:-todo}" in
  copia) copia ;;
  iso)   iso ;;
  usb)   usb ;;
  todo)
    titulo "Migración CachyOS → Kali (kali-deox)"
    echo "   Log: $LOG"
    if [ -n "$(leer_estado copia_ok)" ] && [ -f "$(leer_estado copia_ok)/COPIA-COMPLETA" ]; then
      ok "Ya hay una copia completa en $(leer_estado copia_ok)"
      ask "¿Rehacerla (actualizar con los cambios)?" && copia
    else
      copia
    fi
    ask "¿Seguimos con la ISO de Kali?" && iso
    ask "¿Grabamos el pendrive?" && usb
    instrucciones ;;
  *) sed -n '2,25p' "$0"; exit 1 ;;
esac
