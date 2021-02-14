# Code here runs inside the initialize() function
# Use it for anything that you need to run before any other function, like
# setting environment vairables:
# CONFIG_FILE=settings.ini
#
# Feel free to empty (but not delete) this file.

base_url=${CLOUDENV_BASE_URL:-https://app.cloudenv.com}
debug=${CLOUDENV_DEBUG:-0}

tempdir=$(mktemp -d)
editor="${EDITOR:-nano}"

get_encrypted_env() {
  env=${1:-default}
  execute "curl" "-s" "-H" "\"Authorization: Bearer $(get_bearer)\"" "\"$base_url/api/v1/envs?name=$(get_current_app)&environment=$env&version=$version&lang=cli\""
  echo "$output"
}

get_env() {
  env=${1:-default}
  encrypted_file=$(mktemp)
  output_file=$(mktemp)
  get_encrypted_env $env > "$encrypted_file"
  decrypt_file "$encrypted_file"
  rm -rf "$encrypted_file"
}

encrypt_env() {
  execute "openssl" "enc" "-a" "-aes-256-cbc" "-md" "sha512" "-pass" "pass:\"$(get_current_secret)\"" "-in" "\"$1\"" "-out" "\"$2\"" "2>" "/dev/null"
  echo "$output"
}

decrypt_file() {
  execute "openssl" "enc" "-a" "-aes-256-cbc" "-md" "sha512" "-d" "-pass" "pass:\"$(get_current_secret)\"" "-in" "\"$1\"" "2>" "/dev/null"
  echo "$output"
}

upload_env() {
  encrypted_file=$(mktemp)
  encrypt_env "$1" "$encrypted_file" "$(get_current_secret)"
  curl -s -H "Authorization: Bearer $(get_bearer)" -F "data=@$encrypted_file" "$base_url/api/v1/envs?name=$(get_current_app)&environment=$environment&version=$version&lang=cli" > /dev/null
  rm -rf "$encrypted_file"
}

get_bearer() {
  if [[ -f ~/.cloudenvrc ]]; then
    cat ~/.cloudenvrc | tr -d " \t\n\r"
  fi
}

get_current_app() {
  if [[ -f .cloudenv-secret-key ]]; then
    grep "slug" .cloudenv-secret-key | awk '{print $2}'
  fi
}

get_current_secret() {
  if [[ -f .cloudenv-secret-key ]]; then
    grep "secret-key" .cloudenv-secret-key | awk '{print $2}'
  fi
}

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

abort() {
  printf "%s\n" "$1"
  exit 1
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
  if [ "$debug" -eq 1 ]; then
    echo "EXEC: $(shell_join "$@")"
  fi

  output=$(eval "$@")

  if [ "$debug" -eq 1 ]; then
    echo "GOT: $output" | head -1
    echo
  fi
}

check_logged_in() {
  if [[ ! -f ~/.cloudenvrc ]]; then
    echo
    warn "Not logged in"
    echo
    ohai "Please run: cloudenv login"
    echo
    exit 1
  fi
}

check_for_project() {
  if [[ ! -f .cloudenv-secret-key ]]; then
    echo
    warn "Couldn't find a cloudenv project in $PWD/.cloudenv-secret-key"
    echo
    ohai "Please run: cloudenv init"
    echo
    ohai "Or cd into the root directory of your app to make env edits"
    echo
    exit 1
  fi
}

check_can_read_env() {
  execute "curl" "-s" "-H" "\"Authorization: Bearer $(get_bearer)\"" "\"$base_url/api/v1/apps/show.txt?name=$(get_current_app)&environment=$environment&version=$version&lang=cli\"" "|" "grep $environment" "|" "grep read" "|" "wc" "-l" "|" "xargs"

  if [ "$output" -eq 0 ]; then
    echo
    warn "Your API key does not have read access to $(get_current_app) ($environment environment)"
    echo
    ohai "Please run: cloudenv login"
    echo
    ohai "Or ask your admin for read permissions"
    echo
    exit 1
  fi
}

check_can_write_env() {
  check=$(curl -s -H "Authorization: Bearer $(get_bearer)" "$base_url/api/v1/apps/show.txt?name=$(get_current_app)&environment=$environment&version=$version&lang=cli" | grep "$environment" | grep "write" | wc -l | xargs)
  if [ "$check" -eq 0 ]; then
    echo
    warn "Your API key does not have write access to $(get_current_app) ($environment environment)"
    echo
    ohai "Please run: cloudenv login"
    echo
    ohai "Or ask your admin for write permissions"
    echo
    exit 1
  fi
}

expand_tilde()
{
  local tilde_re='^(~[A-Za-z0-9_.-]*)(.*)'
  local path="$*"
  local pathSuffix=

  if [[ $path =~ $tilde_re ]]; then
    # only use eval on the ~username portion !
    path=$(eval echo ${BASH_REMATCH[1]})
    pathSuffix=${BASH_REMATCH[2]}
  fi

  echo "${path}${pathSuffix}"
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

if ! command -v curl >/dev/null
then
  abort "You must install curl before using cloudenv"
fi

if ! command -v openssl >/dev/null
then
  abort "You must install openssl before using cloudenv"
fi

if ! command -v gpg >/dev/null
then
  abort "You must install gpg before using cloudenv"
fi
