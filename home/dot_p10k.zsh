# ==========================================================================
# ~/.p10k.zsh — Powerlevel10k, estilo powerline (arch-deox · Catppuccin Mocha).
# Config compacta hecha a mano. Para regenerarla a tu gusto: p10k configure
# Requiere una Nerd Font (ttf-jetbrains-mono-nerd) para los iconos/separadores.
# ==========================================================================

# Mantén opciones del shell consistentes mientras se carga esta config.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m 'POWERLEVEL9K_*'

  # --- Segmentos ---
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time time)

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=                       # transparente por defecto
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=

  # --- Separadores powerline ---
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''

  # --- Carácter del prompt (la flecha ❯) ---
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=2    # verde si OK
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=1 # rojo si error
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  # --- os_icon ---
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=4

  # --- context (usuario@host: solo se muestra en SSH/root) ---
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=1
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=5
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='%n'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT_EXPANSION,VISUAL_IDENTIFIER_EXPANSION}=

  # --- dir (directorio actual) ---
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=6
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=232
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40

  # --- vcs (git) ---
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=1
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=232

  # --- status (resultado del último comando) ---
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=232

  # --- command_execution_time (si tarda > 3s) ---
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=3

  # --- time (hora) ---
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=8
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=255
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

  # Refresca el prompt cada segundo (para la hora).
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! ${+functions[p10k]} )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
