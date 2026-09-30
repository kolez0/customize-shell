# Главная точка входа конфигурации customize-zsh.
[[ -o interactive ]] || return

typeset -g _customize_zsh_dir="${${(%):-%N}:A:h}"
typeset -g ZSH_CONFIG_DIR="$_customize_zsh_dir"

for _customize_zsh_module in options history completion tools plugins; do
  [[ -r "$_customize_zsh_dir/${_customize_zsh_module}.zsh" ]] && \
    source "$_customize_zsh_dir/${_customize_zsh_module}.zsh"
done

[[ -r "$_customize_zsh_dir/local.zsh" ]] && source "$_customize_zsh_dir/local.zsh"

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
if (( $+commands[starship] )); then
  function _customize_zsh_select_starship_config() {
    if (( COLUMNS < 120 )); then
      export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/customize-zsh/starship-compact.toml"
    else
      export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
    fi
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _customize_zsh_select_starship_config
  eval "$(starship init zsh)"
fi

unset _customize_zsh_module
