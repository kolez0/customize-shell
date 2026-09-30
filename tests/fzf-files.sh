#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/customize-zsh-fzf.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM
mkdir "$test_dir/bin"

cat > "$test_dir/bin/fd" <<'EOF'
#!/bin/sh
printf '%s\n' example.txt
EOF

cat > "$test_dir/bin/batcat" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" > "$TEST_DIR/preview-args"
EOF

cat > "$test_dir/bin/fzf" <<'EOF'
#!/bin/sh
set -eu
[ "$1" = --preview ]
preview=$(printf '%s' "$2" | sed 's/{}/example.txt/g')
sh -c "$preview"
head -n 1
EOF

chmod +x "$test_dir/bin/fd" "$test_dir/bin/batcat" "$test_dir/bin/fzf"

# zsh expands the inner script.
# shellcheck disable=SC2016
env PATH="$test_dir/bin:/usr/bin:/bin" TEST_DIR="$test_dir" zsh -f -i -c '
  source "$1/config/zsh/tools.zsh"
  customize-zsh-fzf-files
  [[ $LBUFFER == example.txt ]]
' customize-zsh "$project_dir"

[ -f "$test_dir/preview-args" ]
[ "$(cat "$test_dir/preview-args")" = '--color=always --style=numbers --line-range=:500 -- example.txt' ]
