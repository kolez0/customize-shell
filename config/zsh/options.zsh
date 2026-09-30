# Основные настройки интерактивной оболочки.
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt NO_BEEP

typeset -U path PATH
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  path=( "$HOME/.local/bin" $path )
fi
