#!/usr/bin/env bash
# instalar-dotfiles.sh — copia la configuración de dotfiles/ a tu usuario.
# ---------------------------------------------------------------------------
#   bash scripts/instalar-dotfiles.sh            copiar (por defecto)
#   bash scripts/instalar-dotfiles.sh --enlazar  enlaces simbólicos al repo:
#        editas en el repo, haces 'git commit' y tu config queda versionada.
#        (¡no borres ni muevas el repo si usas este modo!)
#
# Antes de pisar nada, guarda tus ficheros en
#   ~/.local/state/kali-deox/copias/<fecha>/
# No usa sudo: solo toca tu carpeta personal. Se puede relanzar sin miedo.
# ---------------------------------------------------------------------------
source "$(dirname "$0")/lib.sh"
no_root

MODO="copiar"
[ "${1:-}" = "--enlazar" ] && MODO="enlazar"

D="$REPO/dotfiles"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
DATOS="$HOME/.local/share/kali-deox"
BIN="$HOME/.local/bin"
COPIAS="$LOG_DIR/copias/$(date +%Y%m%d-%H%M%S)"

# poner origen destino  → copia/enlaza con copia de seguridad si ya existe algo distinto
poner() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then
      [ "$MODO" = copiar ] && return 0
    fi
    mkdir -p "$COPIAS/$(dirname "${dst#"$HOME"/}")"
    mv "$dst" "$COPIAS/${dst#"$HOME"/}"
  fi
  if [ "$MODO" = enlazar ]; then ln -s "$src" "$dst"; else cp "$src" "$dst"; fi
  echo "   → ${dst/#$HOME/\~}"
}

info "Configuración (modo: $MODO)"
poner "$D/hypr/hyprland.lua"        "$CONF/hypr/hyprland.lua"
poner "$D/hypr/hypridle.conf"       "$CONF/hypr/hypridle.conf"
poner "$D/waybar/config.jsonc"      "$CONF/waybar/config.jsonc"
poner "$D/waybar/style.css"         "$CONF/waybar/style.css"
poner "$D/rofi/config.rasi"         "$CONF/rofi/config.rasi"
poner "$D/kitty/kitty.conf"         "$CONF/kitty/kitty.conf"
poner "$D/wlogout/layout"           "$CONF/wlogout/layout"
poner "$D/fastfetch/config.jsonc"   "$CONF/fastfetch/config.jsonc"
poner "$D/zsh/kali-deox.zsh"        "$CONF/zsh/kali-deox.zsh"

# usuario.lua es TUYO: solo se crea la primera vez.
if [ ! -e "$CONF/hypr/usuario.lua" ]; then
  cp "$D/hypr/usuario.lua" "$CONF/hypr/usuario.lua"
  echo "   → ~/.config/hypr/usuario.lua (tus ajustes; no se volverá a tocar)"
fi

info "Scripts deox-* en ~/.local/bin"
for f in "$D"/bin/*; do poner "$f" "$BIN/$(basename "$f")"; chmod +x "$BIN/$(basename "$f")"; done

info "Temas y plantillas en ~/.local/share/kali-deox"
for f in "$D"/temas/*.tema; do poner "$f" "$DATOS/temas/$(basename "$f")"; done
while IFS= read -r -d '' tpl; do
  rel="${tpl#"$D"/}"
  poner "$tpl" "$DATOS/plantillas/$rel"
done < <(find "$D" -type f -name '*.tpl' -print0)

info "Terminal zsh: cargar kali-deox.zsh desde ~/.zshrc"
LINEA='[ -f ~/.config/zsh/kali-deox.zsh ] && source ~/.config/zsh/kali-deox.zsh  # kali-deox'
if grep -qF '# kali-deox' "$HOME/.zshrc" 2>/dev/null; then
  ok "~/.zshrc ya lo carga"
else
  printf '\n%s\n' "$LINEA" >> "$HOME/.zshrc"
  ok "Añadida una línea al final de ~/.zshrc"
fi
if command -v zsh >/dev/null && [ "$(basename "$(getent passwd "$USER" | cut -d: -f7)")" != zsh ]; then
  aviso "Tu shell no es zsh. Para cambiarla:  chsh -s $(command -v zsh)"
fi

info "Aplicar el tema de colores"
tema="$(cat "$DATOS/tema-actual" 2>/dev/null || echo kali-glitch)"
[ -f "$DATOS/temas/$tema.tema" ] || tema="kali-glitch"
KALI_DEOX_DATOS="$DATOS" bash "$BIN/deox-tema" "$tema"

info "Aspecto de las apps GTK/Qt (modo oscuro, iconos, cursor)"
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' 2>/dev/null || true
  ok "Preferencias GTK aplicadas (cámbialas cuando quieras con: nwg-look)"
fi

case ":$PATH:" in
  *":$BIN:"*) ;;
  *) aviso "~/.local/bin no está en tu PATH en esta terminal: cierra y abre la terminal (o reinicia)." ;;
esac
[ -d "$COPIAS" ] && aviso "Tus ficheros anteriores están guardados en: ${COPIAS/#$HOME/\~}"
ok "Dotfiles instalados."
