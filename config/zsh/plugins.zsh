# Плагины загружаются из заранее собранного статического bundle.
typeset -g _customize_zsh_antidote_dir="${ZDOTDIR:-$HOME}/.antidote"
typeset -g _customize_zsh_bundle="$_customize_zsh_dir/antidote_plugins.zsh"

if [[ -r "$_customize_zsh_antidote_dir/antidote.zsh" ]]; then
  source "$_customize_zsh_antidote_dir/antidote.zsh"
  [[ -r "$_customize_zsh_bundle" ]] && source "$_customize_zsh_bundle"
fi

function zplugin-update() {
  local antidote="$_customize_zsh_antidote_dir/antidote.zsh"
  local plugin_list="$_customize_zsh_dir/.zsh_plugins.txt"
  local bundle="$_customize_zsh_bundle"
  local tmp="${bundle}.tmp.$$"

  if [[ ! -r "$antidote" || ! -r "$plugin_list" ]]; then
    print -u2 -- 'customize-zsh: не найден Antidote или список плагинов.'
    return 1
  fi

  if ! antidote update; then
    print -u2 -- 'customize-zsh: Antidote не смог обновить плагины.'
    return 1
  fi

  if ! antidote bundle < "$plugin_list" > "$tmp"; then
    command rm -f -- "$tmp"
    print -u2 -- 'customize-zsh: не удалось пересобрать список плагинов.'
    return 1
  fi

  if ! command mv -f -- "$tmp" "$bundle"; then
    command rm -f -- "$tmp"
    print -u2 -- 'customize-zsh: не удалось заменить bundle плагинов.'
    return 1
  fi

  print -- 'customize-zsh: Antidote и плагины обновлены.'
}
