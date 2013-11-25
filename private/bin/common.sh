#!/usr/bin/env bash

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

azk.color.escape() {
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
  echo "$(azk.color.escape "${color}azk%{reset}:$AZK_DEBUG_PREFIX $@")" >&2
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
