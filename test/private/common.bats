#!/usr/bin/env bats

set -e

load ../test_helper

source `azk root`/private/bin/common.sh

@test "$test_label set colors if have a \$TERM" {
  TERM=xpto
  tput() {
    echo "tput $@";
  }; export -f tput

  run azk.info "info log"
  echo $output
  assert_success "tput setaf 4azktput sgr0: info log"
}

@test "$test_label don't put color if not have a \$TERM" {
  TERM=

  run azk.info "info log"
  assert_success "azk: info log"
}

@test "$test_label add prefix debug if is set" {
  TERM=
  AZK_DEBUG_PREFIX=" [label]"

  run azk.info "info log"
  assert_success "azk: [label] info log"
}

@test "$test_label escape colors and remove not supported" {
  TERM=xpto
  tput() {
    echo "[tput $@]";
  }; export -f tput

  run azk.info "%{unsupporter}info %{red}log%{reset}"
  echo $output
  assert_success "[tput setaf 4]azk[tput sgr0]: info [tput setaf 1]log[tput sgr0]"
}

@test "$test_label check is a parameter" {
  run azk.is_parameter
  assert_failure

  run azk.is_parameter "notparameter"
  assert_failure

  run azk.is_parameter "--"
  assert_failure

  run azk.is_parameter "-"
  assert_failure

  run azk.is_parameter "-a"
  assert_success

  run azk.is_parameter "--a"
  assert_success
}

@test "$test_label generate a uudi" {
  local uuid="883af6ecf05f40379a6dfa9fd6faf995"

  uuidgen() {
    echo "883AF6EC-F05F-4037-9A6D-FA9FD6FAF995";
  }; export -f uuidgen;

  run azk.uuid
  assert_success "$uuid"

  run azk.uuid 15
  assert_success "$(printf "%.15s" "$uuid")"
}

@test "$test_label get a agent_id" {
  ping() {
    if [[ "$@" =~ ^-q\ -c\ 1\ -t\ 1\ (azk-agent|agent)$ ]]; then
      echo "PING azk-agent (172.16.0.4): 56 bytes"
      echo "64 bytes from 172.16.0.4: icmp_seq=0 ttl=64 time=0.556 ms"
      return 0
    fi
    return 1
  }; export -f ping

  export AZK_AGENT_HOST="agent"
  run azk.agent_ip
  assert_success "172.16.0.4"

  export AZK_AGENT_HOST="invalid"
  run azk.agent_ip
  assert_failure "azk: azk-agent not found"

  export SSH_CONNECTION="192.168.115.1 64850 192.168.50.4 22"
  run azk.agent_ip
  assert_success "192.168.50.4"

  export AZK_AGENT_IP="10.0.0.2"
  run azk.agent_ip
  assert_success "10.0.0.2"
}

@test "$test_local calculate a hash" {
  sha1sum() {
    echo "Error" >&2
    return 1
  }

  shasum() {
    echo "shasum -";
  }

  run eval "echo 'foobar' | azk.hash"
  echo $output
  assert_success "shasum"

  sha1sum() {
    echo "sha1sum -"
  }

  export -f sha1sum
  run eval "echo 'foobar' | azk.hash"
  assert_success "sha1sum"
}
