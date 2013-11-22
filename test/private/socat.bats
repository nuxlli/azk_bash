#!/usr/bin/env bats

load ../test_helper

mock_uname() {
  eval '
    uname() {
      [[ "$@" == "-m" ]] && echo "'$1'" && return 0
      [[ "$@" == "-s" ]] && echo "'$2'" && return 0
      return 1
    }; export -f uname
  '
}

@test "$test_label call linux 32" {
  #mocks
  mock_uname i686 Linux
  exec() {
    echo $@
  }; export -f exec

  run socat
  assert_success
  assert_output "$(azk root)/private/socat/linux/socat_x86"
}

@test "$test_label call mac os x" {
  #mocks
  mock_uname i386 Darwin
  exec() {
    echo $@
  }; export -f exec

  run socat
  assert_success
  assert_output "$(azk root)/private/socat/socat_osx"
}

@test "$test_label a system not supported" {
  #mocks
  uname() { exit 1; }
  export -f uname

  echo $PATH
  run socat
  assert_failure "azk-json: SO or architecture is not supported"
}

@test "$test_label forward parameters" {
  run socat -h
  assert_success
  assert_match 'socat by Gerhard Rieger' "$output"
}

@test "$test_label test socat" {
  mkdir -p ${AZK_TEST_DIR}
  socket="${AZK_TEST_DIR}/test_socat.sock"

  ( sleep 0.1; echo -n "socket" | socat - UNIX:$socket ) &
  run socat - UNIX-LISTEN:$socket,crlf
  assert_success
  assert_output "socket"
}
