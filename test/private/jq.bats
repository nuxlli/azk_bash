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
  # mocks
  mock_uname i686 Linux
  exec() {
    echo $@
  }; export -f exec

  run jq
  assert_success
  assert_output "$(azk root)/private/lib/jq/linux/jq_x86"
}

@test "$test_label call mac os x" {
  # mocks
  mock_uname i386 Darwin
  exec() {
    echo $@
  }; export -f exec

  run jq
  assert_success
  assert_output "$(azk root)/private/lib/jq/jq_osx"
}

@test "$test_label a system not supported" {
  # mocks
  uname() { exit 1; }
  export -f uname

  echo $PATH
  run jq
  assert_failure "azk-json: SO or architecture is not supported"
}

@test "$test_label forward parameters" {
  run jq --version
  assert_success
  assert_match 'jq version [0-9]\.[0-9]' "$output"
}

@test "$test_label pipe test" {
  result=$(echo '{ "foo": "bar" }' | jq ".foo")

  run echo "$result"
  assert_success
  assert_equal '"bar"' "${lines[0]}"
}

@test "$test_label clean comments" {
  result=$(echo '{ "foo": "bar" /* comment */ }' | jq -c ".foo")

  run echo "$result"
  assert_success
  assert_equal '"bar"' "${lines[0]}"
}

@test "$test_label more options in filters" {
  result=$(echo '[[1,2], "string", {"a":2}, null]' | jq '.[] | length')
  run echo $(echo "$result" | sed "s:\n: :g")
  assert_success
  assert_output "2 6 1 0"
}

@test "$test_label with options and filters" {
  json='{ "array": ["option 1", "option 2"] }'
  assert_equal "option 1" "$(echo $json | jq -r '.array | .[0]')"

  eval "array=(`echo $json | jq -r '.array | @sh'`)"
  assert_equal "option 1" "${array[0]}"
}

@test "$test_label option to remove comments is optional" {
   json_line='[ 1, 2 ] // Comment line'
  json_multi='[ 1, /* Long comment \n */ 2]'

  run eval "echo '$json_line' | jq -r '. | @sh'"
  assert_failure

  run eval "echo '$json_line' | jq -c -r '. | @sh'"
  assert_success "1 2"

  run eval "echo '$json_multi' | jq -r '. | @sh'"
  assert_failure

  run eval "echo '$json_multi' | jq --raw-output -c '. | @sh'"
  assert_success "1 2"
}
