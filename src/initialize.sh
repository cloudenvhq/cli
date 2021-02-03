# Code here runs inside the initialize() function
# Use it for anything that you need to run before any other function, like
# setting environment vairables:
# CONFIG_FILE=settings.ini
#
# Feel free to empty (but not delete) this file.

BASE_URL=${CLOUDENV_BASE_URL:-https://app.cloudenv.com}

tempdir=$(mktemp -d)
editor="${EDITOR:-nano}"
bearer=`cat ~/.cloudenvrc | tr -d " \t\n\r"`
app=`head -1 .cloudenv-secret-key`
secretkey=`head -2 .cloudenv-secret-key | tail -1`
environment="${args[environment]}"

# string formatters
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

check_logged_in() {
  if [ ! -f ~/.cloudenvrc ]
  then
    echo
    warn "Not logged in"
    echo
    ohai "Please run: cloudenv login"
    echo
    exit
  fi
}

check_for_project() {
  if [ ! -f .cloudenv-secret-key ]
  then
    echo
    warn "Couldn't find a cloudenv project in $PWD/.cloudenv-secret-key"
    echo
    ohai "Please run: cloudenv init"
    echo
    ohai "Or cd into the root directory of your app to make env edits"
    echo
    exit
  fi
}

getc() {
  local save_state
  save_state=$(/bin/stty -g)
  /bin/stty raw -echo
  IFS= read -r -n 1 -d '' "$@"
  /bin/stty "$save_state"
}

version_gt() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -gt "${2#*.}" ]]
}
version_ge() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -ge "${2#*.}" ]]
}
version_lt() {
  [[ "${1%.*}" -lt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -lt "${2#*.}" ]]
}

if ! command -v curl >/dev/null; then
    abort "$(cat <<EOABORT
You must install cURL before using cloudenv
EOABORT
)"
fi

if ! command -v openssl >/dev/null; then
    abort "$(cat <<EOABORT
You must install openssl before using cloudenv
EOABORT
)"
fi
