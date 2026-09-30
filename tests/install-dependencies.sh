#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd "$(dirname "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/customize-zsh-deps.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM
mkdir "$test_dir/bin"

awk '/^trap '\''exit 129'\'' HUP$/ { exit } { print }' "$project_dir/install.sh" > "$test_dir/functions.sh"

cat > "$test_dir/bin/package-manager" <<'EOF'
#!/bin/sh
name=${0##*/}
case "$name:$1" in
  brew:list|dpkg-query:-W|rpm:-q|pacman:-Q)
    for package do :; done
    if [ "$name" = dpkg-query ] && [ "$package" = "$TEST_REMOVED" ]; then
      printf 'deinstall ok config-files'
      exit 0
    fi
    [ "$package" != "$TEST_MISSING" ] || exit 1
    [ "$name" != dpkg-query ] || printf 'install ok installed'
    exit 0
    ;;
esac
printf '%s %s\n' "$name" "$*" >> "$TEST_LOG"
EOF
chmod +x "$test_dir/bin/package-manager"
for manager in brew dpkg-query rpm pacman apt-get dnf; do
  ln -s package-manager "$test_dir/bin/$manager"
done

run_case() {
  platform=$1
  missing=$2
  expected=$3
  removed=${4:-none}
  : > "$test_dir/log"
  TEST_MISSING=$missing TEST_REMOVED=$removed TEST_LOG=$test_dir/log PATH="$test_dir/bin:$PATH" \
    sh -c '
      . "$1/functions.sh"
      PLATFORM=$2
      DISTRO_VERSION=26.04
      has() { return 0; }
      as_root() { "$@"; }
      starship_is_suitable() { return 0; }
      install_dependencies
    ' customize-zsh "$test_dir" "$platform"
  actual=$(cat "$test_dir/log")
  if [ "$actual" != "$expected" ]; then
    printf 'platform=%s missing=%s: expected <%s>, got <%s>\n' "$platform" "$missing" "$expected" "$actual" >&2
    exit 1
  fi
}

for platform in macos debian ubuntu fedora arch; do
  run_case "$platform" none ''
done
run_case macos fzf 'brew install fzf'
run_case debian fzf 'apt-get update
apt-get install -y fzf'
run_case ubuntu fzf 'apt-get update
apt-get install -y fzf'
run_case ubuntu none 'apt-get update
apt-get install -y fzf' fzf
run_case fedora fzf 'dnf install -y fzf'
run_case arch fzf 'pacman -S --needed --noconfirm fzf'
