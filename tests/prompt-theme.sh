#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/customize-zsh-prompt.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

# The inner script is expanded by zsh, not by this shell.
# shellcheck disable=SC2016
env TERM=xterm-256color XDG_CACHE_HOME="$test_dir/cache" XDG_STATE_HOME="$test_dir/state" zsh -f -i -c '
  autoload -Uz promptinit
  promptinit
  prompt adam1
  source "$1/config/zsh/rc.zsh"

  for hook in "${precmd_functions[@]}"; do
    "$hook"
  done

  case "$PROMPT" in
    *"starship prompt"*) ;;
    *) print -u2 -- "Starship prompt was replaced by another zsh theme: $PROMPT"; exit 1 ;;
  esac
' customize-zsh "$project_dir"
