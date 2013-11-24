#!/usr/bin/env bats

load ../test_helper

setup() {
  mkdir -p "$AZK_TEST_DIR"
  cd "$AZK_TEST_DIR"
}

@test "$test_label blank invocation" {
  run azk-exec
  assert_failure
  assert_match '^Usage:.*exec' "${lines[0]}"
}

@test "$test_label require azkfile" {
  run azk-exec /bin/bash
  assert_failure "$(azk azkfile 2>&1)"
}

@test "$test_label require a containers system to execute" {
  # mocks
  exec () {
    if [[ "$@" == "azk-agent-exec exec /bin/bash" ]]; then
      echo "azk-agent-exec"
      exit 0
    fi
    command exec $@
  }; export -f exec

  echo '{}' > "$(create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}")"

  run azk-exec /bin/bash
  echo $output
  assert_success
  assert_output "azk-agent-exec"
}

@test "$test_label provision image-app" {
  echo '{}' > "$(create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}")"

  azk-provision() {
    [[ "$@" == "--get-name app" ]] && echo "azk/apps:image-tag" && exit 0;
    echo "azk-provision $@"; exit 1;
  }; export -f azk-provision

  run azk-exec --final "echo foobar"
  assert_failure
  assert_output "azk-provision app"
}

@test "$test_label run command in image-app" {
  echo '{}' > "$(create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}")"

  azk-provision() {
    [[ "$@" == "--get-name app" ]] && echo "azk/apps:image-tag" && exit 0;
    echo "azk-provision $@"
  }; export -f azk-provision

  docker() {
    echo "$@"
    exit 10;
  }; export -f docker;

  command="/bin/bash -c \"echo foobar\""
  run azk-exec --final $command
  assert_failure
  assert_equal "azk-provision app" "${lines[0]}"
  assert_equal "azk: [exec] running the command '$command'" "${lines[1]}"
  assert_equal "run -v=`pwd`:/app azk/apps:image-tag /bin/bash -c $command" "${lines[2]}"
}

@test "$test_label support interative command" {
  echo '{}' > "$(create_file "${AZK_TEST_DIR}/${AZK_FILE_NAME}")"

  azk-provision() {
    [[ "$@" == "--get-name app" ]] && echo "azk/apps:image-tag" && exit 0;
    echo "azk-provision $@"
  }; export -f azk-provision

  docker() {
    echo "$@"
  }; export -f docker;

  command="/bin/bash"
  export AZK_INTERACTIVE=true
  run azk-exec --final /bin/bash
  echo $output
  assert_success
  assert_equal "run -v=`pwd`:/app -t -i azk/apps:image-tag /bin/bash -c $command" "${lines[2]}"
}
