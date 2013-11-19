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

@test "call linux 32" {
  #mocks
  mock_uname i686 Linux
  exec() {
    echo $@
  }; export -f exec

  run azk-json
  assert_success
  assert_output "$(azk root)/private/jq/linux/jq_x86"
}

@test "call mac os x" {
  #mocks
  mock_uname i386 Darwin
  exec() {
    echo $@
  }; export -f exec

  run azk-json
  assert_success
  assert_output "$(azk root)/private/jq/jq_osx"
}

@test "a system not supported" {
  #mocks
  uname() { exit 1; }
  export -f uname

  run azk-json
  assert_failure "azk-json: SO or architecture is not supported"
}

@test "forward parameters" {
  run azk-json --version
  assert_success
  assert_match 'jq version [0-9]\.[0-9]' "$output"
}

@test "pipe test" {
  result=$(echo '{ "foo": "bar" }' | azk-json ".foo")

  run echo "$result"
  assert_success
  assert_equal '"bar"' "${lines[0]}"
}

@test "clean comments" {
  result=$(echo '{ "foo": "bar" /* comment */ }' | azk-json ".foo")

  run echo "$result"
  assert_success
  assert_equal '"bar"' "${lines[0]}"
}
