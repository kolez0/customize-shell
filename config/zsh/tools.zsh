# Интеграции утилит и пользовательские алиасы.
if (( $+commands[fzf] )); then
  function customize-zsh-fzf-history() {
    local selected
    selected="$(fc -rl 1 | sed 's/^[[:space:]]*[0-9][0-9]*[[:space:]]*//' | fzf)" || return
    [[ -n "$selected" ]] && LBUFFER="$selected"
  }

  zle -N customize-zsh-fzf-history
  bindkey '^R' customize-zsh-fzf-history

  if (( $+commands[fd] || $+commands[fdfind] )); then
    function customize-zsh-fzf-files() {
      local selected
      local -a preview_args
      (( $+commands[bat] || $+commands[batcat] )) && preview_args=(--preview 'bat --color=always --style=numbers --line-range=:500 -- {}')
      selected="$(fd --type f 2>/dev/null | fzf "${preview_args[@]}")" || return
      [[ -n "$selected" ]] && LBUFFER+="${(q)selected}"
    }

    function customize-zsh-fzf-insert-file() {
      local selected
      selected="$(fd --type f 2>/dev/null | fzf)" || return
      [[ -n "$selected" ]] && LBUFFER+="${(q)selected}"
    }

    function customize-zsh-fzf-cd() {
      local selected
      selected="$(fd --type d 2>/dev/null | fzf)" || return
      [[ -n "$selected" ]] && builtin cd -- "$selected"
      zle reset-prompt
    }

    zle -N customize-zsh-fzf-files
    zle -N customize-zsh-fzf-insert-file
    zle -N customize-zsh-fzf-cd
    bindkey '^F' customize-zsh-fzf-files
    bindkey '^T' customize-zsh-fzf-insert-file
    bindkey '^[c' customize-zsh-fzf-cd
  fi
fi

if (( $+commands[fdfind] )) && (( ! $+commands[fd] )); then
  function fd() { command fdfind "$@" }
fi

if (( $+commands[batcat] )) && (( ! $+commands[bat] )); then
  function bat() { command batcat "$@" }
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

if (( $+commands[eza] )); then
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias tree='eza --tree'
fi

(( $+commands[bat] )) && alias cat='bat'
(( $+commands[rg] )) && alias grep='rg'
if (( $+commands[diff] )) && command diff --color=auto /dev/null /dev/null >/dev/null 2>&1; then
  alias diff='command diff --color=auto'
fi
(( $+commands[df] )) && alias df='df -h'
