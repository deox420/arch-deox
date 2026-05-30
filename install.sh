#!/usr/bin/env bash
# ==========================================================================
# install.sh — Bootstrap de arch-deox sobre Arch Linux puro
#
# Qué hace (en orden):
#   1. Comprobaciones previas (Arch, no-root, red, sudo).
#   2. Instala el helper de AUR `paru` (si falta).
#   3. Restaura paquetes nativos desde packages/pkglist-native.txt.
#   4. Restaura paquetes del AUR desde packages/pkglist-aur.txt.
#   5. Despliega dotfiles con `chezmoi init --apply deox420`.
#   6. Habilita los servicios básicos del sistema/usuario.
#
# Diseñado para ser IDEMPOTENTE: se puede ejecutar varias veces sin romper
# nada. Cada paso comprueba el estado antes de actuar.
#
# Uso:
#   ./install.sh                # ejecuta todo
#   ./install.sh --dry-run      # muestra lo que haría, sin cambiar nada
#   SKIP_DOTFILES=1 ./install.sh   # salta el paso de chezmoi
#
# NO ejecutar como root: usa sudo solo donde hace falta.
# ==========================================================================

set -Eeuo pipefail

# --- Config ----------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NATIVE="${REPO_DIR}/packages/pkglist-native.txt"
PKG_AUR="${REPO_DIR}/packages/pkglist-aur.txt"
GH_USER="deox420"

# Servicios que se habilitan (a nivel sistema). Ajusta a tu gusto.
SYSTEM_SERVICES=(
  NetworkManager.service
  systemd-timesyncd.service
)
# Servicios a nivel usuario (--user). P.ej. pipewire si lo gestionas así.
USER_SERVICES=(
  # pipewire.service
  # pipewire-pulse.service
  # wireplumber.service
)

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# --- Utilidades de log -----------------------------------------------------
c_reset=$'\e[0m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'
info()  { printf '%s[*]%s %s\n' "$c_blue"   "$c_reset" "$*"; }
ok()    { printf '%s[+]%s %s\n' "$c_green"  "$c_reset" "$*"; }
warn()  { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*"; }
err()   { printf '%s[x]%s %s\n' "$c_red"    "$c_reset" "$*" >&2; }
die()   { err "$*"; exit 1; }

# run: ejecuta (o solo imprime, si --dry-run) un comando.
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '%s[dry-run]%s %s\n' "$c_yellow" "$c_reset" "$*"
  else
    "$@"
  fi
}

have() { command -v "$1" &>/dev/null; }

# --- Paso 0: comprobaciones previas ---------------------------------------
preflight() {
  info "Comprobaciones previas…"

  [[ -f /etc/arch-release ]] || die "Esto no parece Arch Linux. Aborto."
  [[ "$(id -u)" -ne 0 ]]     || die "No ejecutes install.sh como root. Usa tu usuario (pedirá sudo cuando toque)."
  have sudo || die "Falta 'sudo'. Instálalo primero: pacman -S sudo (como root)."
  have git  || warn "Falta 'git'; se instalará junto a las dependencias de paru."

  # Comprobación de red básica (no fatal en dry-run).
  if ! ping -c1 -W2 archlinux.org &>/dev/null; then
    warn "Sin conectividad con archlinux.org. Los pasos que descargan fallarán."
  fi

  # Refresca el caché de sudo una sola vez al principio.
  info "Validando sudo (puede pedir tu contraseña)…"
  run sudo -v
  ok "Preflight OK."
}

# --- Paso 1: paru (helper de AUR) -----------------------------------------
install_paru() {
  if have paru; then
    ok "paru ya está instalado: $(paru --version 2>/dev/null | head -n1)"
    return
  fi
  info "Instalando paru desde el AUR…"

  # Dependencias mínimas para compilar paquetes del AUR.
  run sudo pacman -S --needed --noconfirm base-devel git

  local tmp
  tmp="$(mktemp -d)"
  info "Clonando paru en $tmp"
  run git clone https://aur.archlinux.org/paru.git "$tmp/paru"
  # makepkg debe correr como usuario normal; -si instala dependencias y el paquete.
  run bash -c "cd '$tmp/paru' && makepkg -si --noconfirm"
  run rm -rf "$tmp"

  have paru && ok "paru instalado." || die "No se pudo instalar paru."
}

# --- Paso 2: paquetes nativos ---------------------------------------------
restore_native() {
  [[ -f "$PKG_NATIVE" ]] || { warn "No existe $PKG_NATIVE; salto nativos."; return; }
  info "Restaurando paquetes nativos desde $(basename "$PKG_NATIVE")…"

  # Filtra comentarios y líneas vacías.
  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$PKG_NATIVE")
  [[ "${#pkgs[@]}" -gt 0 ]] || { warn "Lista nativa vacía; nada que hacer."; return; }

  # --needed hace el paso idempotente: no reinstala lo ya presente.
  run sudo pacman -S --needed --noconfirm -- "${pkgs[@]}"
  ok "Paquetes nativos sincronizados (${#pkgs[@]} en lista)."
}

# --- Paso 3: paquetes del AUR ---------------------------------------------
restore_aur() {
  [[ -f "$PKG_AUR" ]] || { warn "No existe $PKG_AUR; salto AUR."; return; }
  have paru || { warn "paru no disponible; salto AUR."; return; }
  info "Restaurando paquetes del AUR desde $(basename "$PKG_AUR")…"

  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$PKG_AUR")
  [[ "${#pkgs[@]}" -gt 0 ]] || { warn "Lista AUR vacía; nada que hacer."; return; }

  run paru -S --needed --noconfirm -- "${pkgs[@]}"
  ok "Paquetes AUR sincronizados (${#pkgs[@]} en lista)."
}

# --- Paso 4: dotfiles con chezmoi -----------------------------------------
deploy_dotfiles() {
  if [[ "${SKIP_DOTFILES:-0}" == "1" ]]; then
    warn "SKIP_DOTFILES=1; salto despliegue de dotfiles."
    return
  fi
  info "Desplegando dotfiles con chezmoi (usuario GitHub: $GH_USER)…"

  # chezmoi puede venir de pacman o del AUR; si falta, lo instalamos.
  if ! have chezmoi; then
    info "chezmoi no está; instalándolo…"
    run sudo pacman -S --needed --noconfirm chezmoi
  fi

  if [[ -d "${HOME}/.local/share/chezmoi/.git" ]]; then
    # Ya inicializado: solo aplicar. Idempotente.
    info "chezmoi ya inicializado; aplicando cambios."
    warn "Revisa el diff antes de aplicar en producción: chezmoi diff"
    run chezmoi apply
  else
    # Primera vez: init + apply desde el repo de GitHub.
    run chezmoi init --apply "$GH_USER"
  fi
  ok "Dotfiles desplegados."
}

# --- Paso 4b: shell por defecto (zsh) -------------------------------------
set_default_shell() {
  have zsh || { warn "zsh no instalado; salto cambio de shell."; return; }
  local zsh_path; zsh_path="$(command -v zsh)"
  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    ok "zsh ya es tu shell por defecto."
    return
  fi
  info "Tu shell actual es ${SHELL:-desconocido}."
  read -rp "¿Poner zsh como shell por defecto (chsh)? [y/N] " ans
  if [[ "${ans,,}" == "y" ]]; then
    run chsh -s "$zsh_path"
    ok "Shell por defecto -> zsh (efectivo al volver a iniciar sesión)."
  else
    warn "Se mantiene tu shell actual."
  fi
}

# --- Paso 5: servicios -----------------------------------------------------
enable_services() {
  info "Habilitando servicios del sistema…"
  for svc in "${SYSTEM_SERVICES[@]}"; do
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
      ok "  $svc ya habilitado."
    else
      run sudo systemctl enable --now "$svc"
      ok "  $svc habilitado."
    fi
  done

  if [[ "${#USER_SERVICES[@]}" -gt 0 ]]; then
    info "Habilitando servicios de usuario…"
    for svc in "${USER_SERVICES[@]}"; do
      if systemctl --user is-enabled --quiet "$svc" 2>/dev/null; then
        ok "  (user) $svc ya habilitado."
      else
        run systemctl --user enable --now "$svc"
        ok "  (user) $svc habilitado."
      fi
    done
  fi
}

# --- Main ------------------------------------------------------------------
main() {
  [[ "$DRY_RUN" -eq 1 ]] && warn "Modo --dry-run: no se ejecutará ningún cambio real."
  info "Bootstrap arch-deox — repo: $REPO_DIR"

  preflight
  install_paru
  restore_native
  restore_aur
  deploy_dotfiles
  set_default_shell
  enable_services

  ok "Bootstrap completado."
  cat <<'EOF'

Siguientes pasos sugeridos:
  - Revisa servicios:   systemctl --failed
  - Revisa dotfiles:    chezmoi diff
  - Capa de pentest:    ver pentest/ y README (BlackArch por categorías)
EOF
}

main "$@"
