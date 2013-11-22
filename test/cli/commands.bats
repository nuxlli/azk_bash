#!/usr/bin/env bats

load ../test_helper

@test "$test_label commands" {
  run azk-commands
  assert_success
  assert_line "root"
  assert_line "commands"
}

@test "$test_label commands in path with spaces" {
  path="${AZK_TEST_DIR}/my commands"
  cmd="${path}/azk-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run azk-commands
  assert_success
  assert_line "hello"
}

