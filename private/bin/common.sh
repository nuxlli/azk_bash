#!/usr/bin/env bash

azk.resolve_link() {
  readlink "$1"
}

azk.abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(azk.resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

# TODO: Refectory to use a common functions
azk.debug.color() {
  case "${1}" in
    info)
      echo "%{blue}"
      ;;
    error)
      echo "%{red}"
  esac
}

# TODO: Cache this
azk.tput() {
  [ -z "$TERM" ] && return 0
  eval "tput $@"
}

azk.escape() {
  echo "$@" | sed "
    s/%{red}/$(azk.tput setaf 1)/g;
    s/%{green}/$(azk.tput setaf 2)/g;
    s/%{yellow}/$(azk.tput setaf 3)/g;
    s/%{blue}/$(azk.tput setaf 4)/g;
    s/%{magenta}/$(azk.tput setaf 5)/g;
    s/%{cyan}/$(azk.tput setaf 6)/g;
    s/%{white}/$(azk.tput setaf 7)/g;
    s/%{reset}/$(azk.tput sgr0)/g;
    s/%{[a-z]*}//g;
  "
}

azk.debug() {
  local nivel="$1"; shift
  local color="$(azk.debug.color "$nivel")"
  echo "$(azk.escape "${color}azk%{reset}:$AZK_DEBUG_PREFIX $@")" >&2
}

azk.info() {
  azk.debug info "$@"
}

azk.error() {
  azk.debug error "$@"
}

azk.render() {
eval "cat <<EOF
$(echo -en "$1")
EOF
" 2> /dev/null
}

azk.is_parameter() {
  # zero length not is parameter
  [ -z "$1" ] && return 1;

  # -[alpha] --[alpha] is parameter
  [[ "$1" =~ ^--?[a-zA-Z0-9]{1,}$ ]] && return 0;

  return 1;
}

azk.docker_containers() {
  local image=$(azk-provision --get-name app)
  local filter=". | map(select(.Image | contains(\"$image\")))"
  azk-dcli /containers/json | jq -r "$filter"
}

azk.uuid() {
  local size="${1:-32}"
  printf "%.${size}s" "$(uuidgen | sed 's:\-::g' | awk '{print tolower($0)}')"
}

azk.redis() {
    ip=`azk.agent_ip`
  port=49153
  exec 6<>/dev/tcp/$ip/$port
  if [ $? -ne 0 ]; then
    azk.error "[redis] dont connect to redis"
    exit 1
  fi
  redis-client "$@"
}

# TODO: Add support ipv6
azk.valid_ip() {
  local ip=$1
  local stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
        && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

azk.agent_ip() {
  # Forcefully
  if [ ! -z "$AZK_AGENT_IP" ]; then
    echo $AZK_AGENT_IP
    return 0
  fi

  # From ssh connection
  azk_agent_ip="$(echo $SSH_CONNECTION | awk '{printf $3}')"
  if [ ! -z "$azk_agent_ip" ]; then
    echo $azk_agent_ip
    return 0
  fi

  # Via hostname
  AZK_AGENT_HOST="${AZK_AGENT_HOST:-azk-agent}"
  azk_agent_ip="$( \
    ping -q -c 1 -t 1 $AZK_AGENT_HOST | \
    grep PING | sed -e "s/).*//" | \
    sed -e "s/.*(//" \
  )"

  if azk.valid_ip "$azk_agent_ip"; then
    echo $azk_agent_ip;
    return 0;
  fi

  azk.error "azk-agent not found"
  return 1;
}

azk.hash() {
  { sha1sum 2>/dev/null || shasum; } | awk '{print $1}'
}

azk.escape_path() {
  echo $(echo $@ | sed 's/\//\\\//g')
}

# TODO: Check this is test in linux
azk.resolve_app_agent_dir() {
  local actual="${1:-`pwd`}"
  local base="${AZK_AGENT_APPS_PATH:-/home/core/azk/data/apps}"

  # Valid subdirectory
  local path="$(echo $actual| sed 's/'"$(azk.escape_path $AZK_APPS_PATH)"'//g')"
  [[ "$path" != "$actual" ]] && echo $base$path && return 0

  # Not valid app path
  azk.error "not in azk applications path"
  return 1
}
