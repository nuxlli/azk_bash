#!/usr/bin/env bats

load ../test_helper

@test "$test_label blank invocation" {
  run azk
  assert_success
  assert [ "${lines[0]}" = "azk 0.1.0" ]
}

@test "$test_label invalid command" {
  run azk does-not-exist
  assert_failure
  assert_output "azk: no such command \`does-not-exist'"
}

@test "$test_label show version" {
  run azk -v
  assert_success
  assert [ "${lines[0]}" = "azk 0.1.0" ]
}

@test "$test_label default AZK_ROOT" {
  AZK_ROOT="" run azk root
  assert_success
  assert_output "$_AZK_PATH"
}

@test "$test_label inherited AZK_ROOT" {
  AZK_ROOT=/opt/azk run azk root
  assert_success
  assert_output "/opt/azk"
}

@test "$test_label default AZK_DIR" {
  run azk echo AZK_DIR
  assert_output "$(pwd)"
}

@test "$test_label inherited AZK_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  AZK_DIR="$dir" run azk echo AZK_DIR
  assert_output "$dir"
}

@test "$test_label invalid AZK_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  AZK_DIR="$dir" run azk echo AZK_DIR
  assert_failure
  assert_output "azk: cannot change working directory to \`$dir'"
}
