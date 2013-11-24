#!/usr/bin/env bats

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