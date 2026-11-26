# ~/.config/zsh/kali-deox.zsh — extras de terminal de kali-deox.
# Se carga desde tu ~/.zshrc (el instalador añade UNA línea al final; el
# .zshrc de Kali se queda como está).

# --- Scripts deox-* (~/.local/bin) en el PATH ---
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"

# --- Prompt bonito (starship) si está instalado ---
command -v starship >/dev/null && eval "$(starship init zsh)"

# --- Saltar a carpetas recientes con 'z carpeta' ---
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# --- Búsqueda difusa en el historial (Ctrl+R) y ficheros (Ctrl+T) ---
if [[ -o interactive && -t 0 ]] && command -v fzf >/dev/null; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null
fi

# --- Alias cómodos ---
command -v eza    >/dev/null && alias ls='eza --icons --group-directories-first' && alias ll='eza -la --icons --git'
command -v batcat >/dev/null && alias cat='batcat --paging=never --style=plain'
command -v fdfind >/dev/null && alias fd='fdfind'
alias actualizar='sudo apt update && sudo apt full-upgrade'
alias ip-vpn='deox-vpn-ip'
alias puertos='sudo ss -tulpn'
alias servir='python3 -m http.server 8000'          # compartir ficheros con el objetivo
alias wl='ls /usr/share/wordlists /usr/share/seclists'

# --- $OBJETIVO = máquina que estás auditando (fijada con deox-objetivo) ---
_deox_objetivo() { local f="${XDG_CACHE_HOME:-$HOME/.cache}/kali-deox/objetivo"; [ -s "$f" ] && export OBJETIVO="$(<"$f")" || unset OBJETIVO; }
autoload -Uz add-zsh-hook && add-zsh-hook precmd _deox_objetivo

# --- Carpeta de trabajo por máquina: 'caja nombre' crea ~/cajas/nombre/{nmap,loot,exploits,notas.md} ---
caja() {
  [ -n "$1" ] || { echo "Uso: caja <nombre>"; return 1; }
  mkdir -p ~/cajas/"$1"/{nmap,loot,exploits} && touch ~/cajas/"$1"/notas.md && cd ~/cajas/"$1" || return
  echo "Carpeta lista: $PWD"
}

# --- Resumen del sistema al abrir una terminal (quítalo si te molesta) ---
[[ -o interactive ]] && command -v fastfetch >/dev/null && [ -z "$KALI_DEOX_SIN_FASTFETCH" ] && fastfetch
