#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "blank invocation" {
  run azk-exec
  assert_failure
  assert_match '^Usage:.*exec' "${lines[0]}"
}

@test "require azkfile" {
  run azk-exec /bin/bash
  assert_failure "$(azk azkfile 2>&1)"
}

@test "require a containers system to execute" {
  # mocks
  azk-agent-exec () {
    [[ "$@" == "exec /bin/bash" ]] && echo "azk-agent-exec" && exit 0
    exit 1
  }; export -f azk-agent-exec

  create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}"

  run azk-exec /bin/bash
  assert_success
  assert_output "azk-agent-exec"
}

@test "execute command if is finnaly" {
  create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}"

  run azk-exec --final "echo foobar"
  assert_success
  assert_output "foobar"
}
