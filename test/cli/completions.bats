#!/usr/bin/env bats

load ../test_helper

create_command() {
  bin="${AZK_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "$test_label command with no completion support" {
  create_command "azk-hello" "#!$BASH
    echo hello"
  run azk-completions hello
  assert_success ""
}

@test "$test_label command with completion support" {
  create_command "azk-hello" "#!$BASH
# provide azk completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run azk-completions hello
  assert_success "hello"
}

@test "$test_label forwards extra arguments" {
  create_command "azk-hello" "#!$BASH
# provide azk completions
if [[ \$1 = --complete ]]; then
  shift 1
  for arg; do echo \$arg; done
else
  exit 1
fi"
  run azk-completions hello happy world
  assert_success
  assert_output <<OUT
happy
world
OUT
}
